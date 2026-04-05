import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../db/customer_repository.dart';
import '../../db/delivery_repository.dart';
import '../../db/settings_repository.dart';
import '../../models/customer.dart';
import '../../models/delivery.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';
import '../../widgets/quantity_chips.dart';

// ─── Phase ────────────────────────────────────────────────────────────────────

enum _Phase {
  loading,   // awaiting async init
  recovery,  // showing crash-recovery dialog
  entry,     // active entry flow
  saving,    // SAVE ALL in progress
  success,   // all confirmed, success screen
  empty,     // no active customers
}

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Delivery entry session screen.
///
/// Architecture:
///  - Write-on-confirm: every "Confirm" tap UPSERTs a session_draft immediately.
///    If the app is killed mid-session, recovery picks up on next launch.
///  - UPSERT: Previous → change qty → re-confirm overwrites the draft row,
///    never creates a duplicate. Prevents double-billing.
///  - Crash recovery: on init, queries session_draft records from today for
///    this device. If found, offers to resume or discard.
///  - Offstage: next customer card is pre-built (invisible) to trigger
///    Noto Nastalikh font shaping (8–15 ms on Helio G25) before the transition.
///  - Balance: cached_balance NOT updated per-draft.
///    adjustCachedBalance() called once per customer at SAVE ALL time.
///  - Success screen never auto-dismisses — it is the customer receipt.
class DeliveryEntryScreen extends ConsumerStatefulWidget {
  const DeliveryEntryScreen({super.key});

  @override
  ConsumerState<DeliveryEntryScreen> createState() => _DeliveryEntryState();
}

class _DeliveryEntryState extends ConsumerState<DeliveryEntryScreen> {
  _Phase _phase = _Phase.loading;

  // ── Session data ────────────────────────────────────────────────────────────
  List<Customer> _customers = [];
  double _price = 0.0;
  String _deviceId = '';
  String _sessionId = '';

  // ── Per-customer entry state ────────────────────────────────────────────────
  // Both maps persist through back/forward navigation.
  int _currentIndex = 0;
  final Map<String, String> _numpadValues = {};   // customerId → numpad string
  final Map<String, Delivery> _savedDrafts = {};  // customerId → last written draft

  // ── Crash recovery ──────────────────────────────────────────────────────────
  List<Delivery> _recoverableDrafts = [];

  final _deliveryRepo = DeliveryRepository();
  final _customerRepo = CustomerRepository();
  final _avatarScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _avatarScroll.dispose();
    super.dispose();
  }

  // ── Init ─────────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    final customers = await _customerRepo.getActiveCustomers();
    final price     = await _customerRepo.getCurrentPrice();
    final deviceId  = await SettingsRepository.instance.getDeviceId();
    if (!mounted) return;

    if (customers.isEmpty) {
      setState(() => _phase = _Phase.empty);
      return;
    }

    final drafts = await _deliveryRepo.getTodayIncompleteDrafts(deviceId);
    if (!mounted) return;

    // Pre-fill numpad from each customer's default quantity
    for (final c in customers) {
      _numpadValues[c.customerId] = _litersStr(c.defaultLiters);
    }

    setState(() {
      _customers = customers;
      _price     = price;
      _deviceId  = deviceId;
      if (drafts.isNotEmpty) {
        _recoverableDrafts = drafts;
        _phase = _Phase.recovery;
      } else {
        _sessionId = const Uuid().v4();
        _phase = _Phase.entry;
      }
    });

    if (_recoverableDrafts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showRecoveryDialog());
    }
  }

  // ── Crash recovery ────────────────────────────────────────────────────────────

  void _showRecoveryDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'ادھوری ترسیل ملی',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'آج ${_recoverableDrafts.length} گاہکوں کی ترسیل محفوظ نہیں ہوئی۔\n\nجاری رکھیں؟',
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeSession();
            },
            child: const Text('جاری رکھیں', textDirection: TextDirection.rtl),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kAlertRed),
            onPressed: () {
              Navigator.of(ctx).pop();
              _discardAndRestart();
            },
            child: const Text('نئی شروع کریں', textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );
  }

  void _resumeSession() {
    final draftsMap = {for (final d in _recoverableDrafts) d.customerId: d};

    // Restore numpad values from recovered drafts
    for (final d in _recoverableDrafts) {
      _numpadValues[d.customerId] = _litersStr(d.liters);
    }

    // Resume at the first customer not yet in the drafts map
    int resumeIndex = _customers.length - 1; // fallback: last customer
    for (int i = 0; i < _customers.length; i++) {
      if (!draftsMap.containsKey(_customers[i].customerId)) {
        resumeIndex = i;
        break;
      }
    }

    setState(() {
      _sessionId = _recoverableDrafts.first.sessionId!;
      _savedDrafts.addAll(draftsMap);
      _currentIndex = resumeIndex;
      _phase = _Phase.entry;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
  }

  Future<void> _discardAndRestart() async {
    if (_recoverableDrafts.isNotEmpty) {
      await _deliveryRepo.abandonSession(_recoverableDrafts.first.sessionId!);
    }
    if (!mounted) return;
    setState(() {
      _recoverableDrafts = [];
      _sessionId = const Uuid().v4();
      _phase = _Phase.entry;
    });
  }

  // ── Entry actions ─────────────────────────────────────────────────────────────

  Future<void> _confirmCurrent() async {
    HapticFeedback.selectionClick();

    final c      = _customers[_currentIndex];
    final liters = double.tryParse(_numpadValues[c.customerId] ?? '') ?? c.defaultLiters;
    final price  = c.priceOverride ?? _price;
    final today  = DateTime.now().toIso8601String().substring(0, 10);

    // Write-on-confirm: UPSERT as session_draft immediately.
    // Previous + re-confirm: overwrites the existing draft, no duplicate row.
    final draft = await _deliveryRepo.upsertSessionDraft(
      sessionId:     _sessionId,
      customerId:    c.customerId,
      date:          today,
      liters:        liters,
      pricePerLiter: price,
      deviceId:      _deviceId,
    );

    _savedDrafts[c.customerId] = draft;

    if (_currentIndex < _customers.length - 1) {
      setState(() => _currentIndex++);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
    } else {
      await _doSaveAll();
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex--);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
    }
  }

  Future<void> _doSaveAll() async {
    setState(() => _phase = _Phase.saving);

    // Promote all session_draft → confirmed in a single UPDATE
    await _deliveryRepo.confirmSession(_sessionId);

    // Adjust cached_balance per customer (O(1) delta each)
    for (final draft in _savedDrafts.values) {
      await _customerRepo.adjustCachedBalance(draft.customerId, draft.totalValue);
    }

    // Invalidate so home screen and reports see fresh data
    ref.invalidate(todayDeliveriesProvider);

    setState(() => _phase = _Phase.success);
  }

  // ── Discard / back ────────────────────────────────────────────────────────────

  Future<bool> _confirmDiscard() async {
    if (_savedDrafts.isEmpty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'ترسیل چھوڑیں؟',
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          '${_savedDrafts.length} گاہکوں کا ڈیٹا ضائع ہو جائے گا۔',
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('جاری رکھیں', textDirection: TextDirection.rtl),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kAlertRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('چھوڑیں', textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );

    if (result == true) await _deliveryRepo.abandonSession(_sessionId);
    return result ?? false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static String _litersStr(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _scrollAvatarTo(int index) {
    if (!_avatarScroll.hasClients) return;
    const itemWidth = 60.0; // avatar 40dp + padding + gap
    final target = (index * itemWidth)
        .clamp(0.0, _avatarScroll.position.maxScrollExtent);
    _avatarScroll.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSuccess = _phase == _Phase.success;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (isSuccess) { context.go('/home'); return; }
        if (_phase == _Phase.entry) {
          if (await _confirmDiscard()) {
            if (mounted) context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: isSuccess ? kGreen : kCream,
        appBar: _phase == _Phase.entry
            ? AppBar(
                backgroundColor: kCream,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  '${_savedDrafts.length} / ${_customers.length}',
                  style: const TextStyle(
                    color: kInkBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: kInkBlack),
                  onPressed: () async {
                    if (await _confirmDiscard()) {
                      if (mounted) context.pop();
                    }
                  },
                ),
              )
            : null,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _Phase.loading || _Phase.recovery || _Phase.saving =>
          const Center(child: CircularProgressIndicator(color: kGreen)),
      _Phase.empty => _EmptyState(onAddCustomer: () => context.go('/customers/new')),
      _Phase.success => _SuccessScreen(
          drafts: _savedDrafts.values.toList(),
          onDone: () => context.go('/home'),
          onPayment: () => context.go('/payment/entry'),
        ),
      _Phase.entry => _buildEntryBody(),
    };
  }

  Widget _buildEntryBody() {
    final c       = _customers[_currentIndex];
    final hasNext = _currentIndex < _customers.length - 1;
    final isLast  = !hasNext;

    return Column(
      children: [
        _AvatarStrip(
          customers: _customers,
          currentIndex: _currentIndex,
          confirmedIds: _savedDrafts.keys.toSet(),
          scrollController: _avatarScroll,
        ),
        const Divider(height: 1, color: kSurfaceGray),
        Expanded(
          child: Stack(
            children: [
              // Current customer card
              _CustomerEntryCard(
                key: ValueKey(c.customerId),
                customer: c,
                numpadValue: _numpadValues[c.customerId] ?? '',
                price: c.priceOverride ?? _price,
                onNumpadChanged: (v) => setState(() => _numpadValues[c.customerId] = v),
                onQtyChip: (q) => setState(() => _numpadValues[c.customerId] = _litersStr(q)),
                onConfirm: _confirmCurrent,
                onPrevious: _currentIndex > 0 ? _goPrevious : null,
                isLast: isLast,
              ),
              // Next card: Offstage — pre-renders widget tree without painting.
              // Triggers Noto Nastalikh font shaping (8–15 ms on Helio G25)
              // before the transition animation begins.
              if (hasNext)
                Offstage(
                  offstage: true,
                  child: _CustomerEntryCard(
                    key: ValueKey('pre_${_customers[_currentIndex + 1].customerId}'),
                    customer: _customers[_currentIndex + 1],
                    numpadValue: _numpadValues[_customers[_currentIndex + 1].customerId] ?? '',
                    price: _customers[_currentIndex + 1].priceOverride ?? _price,
                    onNumpadChanged: (_) {},
                    onQtyChip: (_) {},
                    onConfirm: () {},
                    onPrevious: null,
                    isLast: _currentIndex + 1 == _customers.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Avatar strip ─────────────────────────────────────────────────────────────

class _AvatarStrip extends StatelessWidget {
  final List<Customer> customers;
  final int currentIndex;
  final Set<String> confirmedIds;
  final ScrollController scrollController;

  const _AvatarStrip({
    required this.customers,
    required this.currentIndex,
    required this.confirmedIds,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: customers.length,
        itemBuilder: (ctx, i) {
          final c         = customers[i];
          final isCurrent = i == currentIndex;
          final isDone    = confirmedIds.contains(c.customerId);
          final initial   = c.name.trim().isNotEmpty
              ? c.name.trim()[0].toUpperCase()
              : '?';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? kGreen
                    : isDone
                        ? kGreen.withOpacity(0.15)
                        : kSurfaceGray,
                border: isCurrent
                    ? Border.all(color: kGreenDark, width: 2)
                    : null,
              ),
              child: isDone && !isCurrent
                  ? const Icon(Icons.check, color: kGreen, size: 18)
                  : Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? kWhite : kMittiBrown,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Customer entry card ──────────────────────────────────────────────────────

/// One customer's entry card.
///
/// Stateless — parent owns all mutable state.
/// SingleChildScrollView ensures it fits on 5" screens (Tecno Spark / Infinix Hot).
class _CustomerEntryCard extends StatelessWidget {
  final Customer customer;
  final String numpadValue;
  final double price;
  final ValueChanged<String> onNumpadChanged;
  final ValueChanged<double> onQtyChip;
  final VoidCallback onConfirm;
  final VoidCallback? onPrevious;
  final bool isLast;

  const _CustomerEntryCard({
    super.key,
    required this.customer,
    required this.numpadValue,
    required this.price,
    required this.onNumpadChanged,
    required this.onQtyChip,
    required this.onConfirm,
    required this.onPrevious,
    required this.isLast,
  });

  double? get _liters => double.tryParse(numpadValue);
  double get _total   => ((_liters ?? 0) * price * 100).round() / 100;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Customer header ────────────────────────────────────────────────
          Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kSurfaceGray,
                child: Text(
                  customer.name.trim().isNotEmpty
                      ? customer.name.trim()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kMittiBrown,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      customer.name,
                      textDirection: TextDirection.rtl,
                      style: kHeadlineStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _BalanceLabel(balance: customer.cachedBalance),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quantity chips ─────────────────────────────────────────────────
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'مقدار (لیٹر)',
              textDirection: TextDirection.rtl,
              style: kLabelStyle,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: QuantityChips(selected: _liters, onSelected: onQtyChip),
          ),
          const SizedBox(height: 16),

          // ── Liters display — read-only, NumpadWidget provides all input ────
          // System keyboard MUST NOT appear for any number field.
          Container(
            height: kInputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: numpadValue.isNotEmpty ? kGreen : kMutedGray,
                width: numpadValue.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  numpadValue.isEmpty ? '0 لیٹر' : '$numpadValue لیٹر',
                  style: kTitleStyle.copyWith(
                    color: numpadValue.isEmpty ? kMutedGray : kInkBlack,
                  ),
                ),
                _liters != null && _liters! > 0 && price > 0
                    ? Text(
                        '₹${_total.toStringAsFixed(2)}',
                        style: kBodyLgStyle.copyWith(
                          color: kGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        '₹${price.toStringAsFixed(0)}/لیٹر',
                        style: kBodyStyle.copyWith(color: kMutedGray),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Custom numpad — system keyboard never shown for numbers ────────
          NumpadWidget(value: numpadValue, onChanged: onNumpadChanged),
          const SizedBox(height: 16),

          // ── Confirm — kConfirmButtonHeight (72dp) ──────────────────────────
          SizedBox(
            height: kConfirmButtonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              child: Text(
                isLast ? 'آخری تصدیق' : 'تصدیق کریں',
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── Previous ───────────────────────────────────────────────────────
          if (onPrevious != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: kButtonHeight,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPrevious,
                child: const Text(
                  'پچھلا گاہک',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Balance label ────────────────────────────────────────────────────────────

class _BalanceLabel extends StatelessWidget {
  final double balance;
  const _BalanceLabel({required this.balance});

  @override
  Widget build(BuildContext context) {
    if (balance > 0) {
      return Text(
        'باقی: ₹${balance.toStringAsFixed(2)}',
        textDirection: TextDirection.rtl,
        style: kBodyStyle.copyWith(color: kAlertRed),
      );
    } else if (balance < 0) {
      return Text(
        'اضافی: ₹${(-balance).toStringAsFixed(2)}',
        textDirection: TextDirection.rtl,
        style: kBodyStyle.copyWith(color: kGreen),
      );
    }
    return Text(
      'ادائیگی صاف',
      textDirection: TextDirection.rtl,
      style: kBodyStyle.copyWith(color: kGreen),
    );
  }
}

// ─── Success screen ───────────────────────────────────────────────────────────

/// Session receipt screen — shown to the customer as proof of delivery.
///
/// NEVER auto-dismisses. User must tap "ہو گیا" explicitly.
/// "ادائیگی درج کریں" is the primary payment discovery mechanism.
class _SuccessScreen extends StatelessWidget {
  final List<Delivery> drafts;
  final VoidCallback onDone;
  final VoidCallback onPayment;

  const _SuccessScreen({
    required this.drafts,
    required this.onDone,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final totalLiters = drafts.fold(0.0, (s, d) => s + d.liters);
    final totalValue  = drafts.fold(0.0, (s, d) => s + d.totalValue);
    final today       = DateTime.now();
    final dateStr     = '${today.day}/${today.month}/${today.year}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            const Icon(Icons.check_circle_outline, color: kWhite, size: 80),
            const SizedBox(height: 20),

            const Text(
              'تمام دودھ محفوظ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: kWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateStr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kWhite, fontSize: 16),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kGreenDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'گاہک', value: '${drafts.length}'),
                  const SizedBox(height: 14),
                  const Divider(color: kGreen, height: 1),
                  const SizedBox(height: 14),
                  _SummaryRow(
                    label: 'کل دودھ',
                    value: '${totalLiters.toStringAsFixed(1)} لیٹر',
                  ),
                  const SizedBox(height: 14),
                  _SummaryRow(
                    label: 'کل رقم',
                    value: '₹${totalValue.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Payment nudge — primary discovery mechanism for payment recording
            SizedBox(
              height: kButtonHeight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kWhite,
                  side: const BorderSide(color: kWhite, width: 1.5),
                ),
                onPressed: onPayment,
                child: const Text(
                  'ادائیگی درج کریں',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Done — NEVER auto-dismiss
            SizedBox(
              height: kConfirmButtonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kWhite,
                  foregroundColor: kGreen,
                ),
                onPressed: onDone,
                child: const Text(
                  'ہو گیا',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: kWhite, fontSize: 16)),
        Text(value,
            style: const TextStyle(
                color: kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddCustomer;
  const _EmptyState({required this.onAddCustomer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64, color: kMutedGray),
            const SizedBox(height: 16),
            const Text(
              'کوئی گاہک نہیں',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                color: kMittiBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'پہلے گاہک شامل کریں',
              textDirection: TextDirection.rtl,
              style: kBodyStyle,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddCustomer,
              child: const Text(
                'گاہک شامل کریں',
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
