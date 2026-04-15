import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/analytics_service.dart';
import '../../db/customer_repository.dart';
import '../../db/delivery_repository.dart';
import '../../db/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../models/delivery.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';
import '../../widgets/quantity_chips.dart';

// ─── Phase ────────────────────────────────────────────────────────────────────

enum _Phase {
  loading, // awaiting async init
  recovery, // showing crash-recovery dialog
  entry, // active entry flow
  saving, // SAVE ALL in progress
  success, // all confirmed, success screen
  empty, // no active customers
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
  final Map<String, String> _numpadValues = {}; // customerId → numpad string
  final Map<String, Delivery> _savedDrafts =
      {}; // customerId → last written draft
  final Set<String> _editedCustomerIds = <String>{};
  final Set<String> _skippedCustomerIds = <String>{};
  List<Delivery> _successDrafts = const [];
  String? _successPaymentCustomerId;

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
    final price = await _customerRepo.getCurrentPrice();
    final deviceId = await SettingsRepository.instance.getDeviceId();
    if (!mounted) return;

    if (customers.isEmpty) {
      setState(() => _phase = _Phase.empty);
      return;
    }

    final drafts = await _deliveryRepo.getTodayIncompleteDrafts(deviceId);
    if (!mounted) return;

    setState(() {
      _customers = customers;
      _price = price;
      _deviceId = deviceId;
      if (drafts.isNotEmpty) {
        _recoverableDrafts = drafts;
        _phase = _Phase.recovery;
      } else {
        _sessionId = const Uuid().v4();
        _phase = _Phase.entry;
      }
    });

    if (_recoverableDrafts.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showRecoveryDialog());
    }
  }

  // ── Crash recovery ────────────────────────────────────────────────────────────

  void _showRecoveryDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.recoveryTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.recoveryBody,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeSession();
            },
            child: Text(l10n.recoveryContinue),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kAlertRed),
            onPressed: () {
              Navigator.of(ctx).pop();
              _discardAndRestart();
            },
            child: Text(l10n.recoveryRestart),
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

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
  }

  Future<void> _discardAndRestart() async {
    if (_recoverableDrafts.isNotEmpty) {
      await _deliveryRepo.abandonSession(_recoverableDrafts.first.sessionId!);
    }
    if (!mounted) return;
    setState(() {
      _recoverableDrafts = [];
      _sessionId = const Uuid().v4();
      _currentIndex = 0;
      _numpadValues.clear();
      _savedDrafts.clear();
      _editedCustomerIds.clear();
      _skippedCustomerIds.clear();
      _phase = _Phase.entry;
    });
  }

  // ── Entry actions ─────────────────────────────────────────────────────────────

  Future<void> _confirmCurrent() async {
    HapticFeedback.selectionClick();
    final l10n = AppLocalizations.of(context)!;

    final c = _customers[_currentIndex];
    final raw = (_numpadValues[c.customerId] ?? '').trim();
    final liters = double.tryParse(raw);
    if (liters == null || liters <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deliveryInvalidQuantity),
          ),
        );
      }
      return;
    }
    final price = c.priceOverride ?? _price;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Write-on-confirm: UPSERT as session_draft immediately.
    // Previous + re-confirm: overwrites the existing draft, no duplicate row.
    final draft = await _deliveryRepo.upsertSessionDraft(
      sessionId: _sessionId,
      customerId: c.customerId,
      date: today,
      liters: liters,
      pricePerLiter: price,
      deviceId: _deviceId,
    );

    _savedDrafts[c.customerId] = draft;
    _skippedCustomerIds.remove(c.customerId);
    _editedCustomerIds.remove(c.customerId);

    if (_currentIndex < _customers.length - 1) {
      setState(() => _currentIndex++);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
    } else {
      await _doSaveAll();
    }
  }

  Future<void> _clearCurrentEntry() async {
    if (_customers.isEmpty || _sessionId.isEmpty) return;

    HapticFeedback.selectionClick();
    final current = _customers[_currentIndex];
    await _deliveryRepo.deleteSessionDraftForCustomer(
      _sessionId,
      current.customerId,
    );

    if (!mounted) return;
    setState(() {
      _numpadValues[current.customerId] = '';
      _savedDrafts.remove(current.customerId);
      _skippedCustomerIds.remove(current.customerId);
      _editedCustomerIds.remove(current.customerId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.deliveryEntryCleared),
      ),
    );
  }

  Future<void> _skipCurrent() async {
    if (_customers.isEmpty) return;

    HapticFeedback.selectionClick();
    final current = _customers[_currentIndex];
    if (_sessionId.isNotEmpty) {
      await _deliveryRepo.deleteSessionDraftForCustomer(
        _sessionId,
        current.customerId,
      );
    }

    if (!mounted) return;
    setState(() {
      _numpadValues[current.customerId] = '';
      _savedDrafts.remove(current.customerId);
      _editedCustomerIds.remove(current.customerId);
      _skippedCustomerIds.add(current.customerId);
    });

    if (_currentIndex < _customers.length - 1) {
      setState(() => _currentIndex++);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
      return;
    }

    if (_savedDrafts.isNotEmpty) {
      await _doSaveAll();
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deliveryAllSkipped),
        ),
      );
      context.go('/home');
    }
  }

  void _jumpToCustomer(int index) {
    if (index < 0 || index >= _customers.length || index == _currentIndex) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex--);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollAvatarTo(_currentIndex));
    }
  }

  Future<void> _doSaveAll() async {
    setState(() => _phase = _Phase.saving);

    final successDrafts = List<Delivery>.of(_savedDrafts.values);
    final successPaymentCustomerId =
        successDrafts.length == 1 ? successDrafts.first.customerId : null;

    // Promote all session_draft → confirmed in a single UPDATE
    await _deliveryRepo.confirmSession(_sessionId);
    await AnalyticsService.instance.trackButtonClicked(
      buttonName: 'save_delivery',
      screenName: 'Delivery Entry',
      routeName: '/delivery/entry',
      elementType: 'button',
      elementText: 'Save Delivery',
    );
    await AnalyticsService.instance.trackFeatureUsed(
      featureName: 'delivery_entry',
      screenName: 'Delivery Entry',
      routeName: '/delivery/entry',
      liters: successDrafts.fold<double>(0, (sum, item) => sum + item.liters),
    );

    // Adjust cached_balance per customer (O(1) delta each)
    for (final draft in _savedDrafts.values) {
      await _customerRepo.adjustCachedBalance(
          draft.customerId, draft.totalValue);
    }

    // Invalidate so home screen and reports see fresh data
    ref.invalidate(todayDeliveriesProvider);
    final now = DateTime.now();
    ref.invalidate(monthlySummaryProvider(now.year, now.month));

    setState(() {
      _successDrafts = successDrafts;
      _successPaymentCustomerId = successPaymentCustomerId;
      _phase = _Phase.success;
    });
  }

  // ── Discard / back ────────────────────────────────────────────────────────────

  bool get _hasUnsavedCurrentValue {
    if (_customers.isEmpty) return false;
    final current = _customers[_currentIndex];
    final raw = (_numpadValues[current.customerId] ?? '').trim();
    if (raw.isEmpty) return false;
    final liters = double.tryParse(raw);
    return liters != null && liters > 0;
  }

  bool get _hasSessionProgress =>
      _savedDrafts.isNotEmpty ||
      _skippedCustomerIds.isNotEmpty ||
      _hasUnsavedCurrentValue;

  Future<void> _saveCurrentForResumeIfNeeded() async {
    if (_customers.isEmpty) return;

    final current = _customers[_currentIndex];
    final raw = (_numpadValues[current.customerId] ?? '').trim();
    final liters = double.tryParse(raw);
    if (liters == null || liters <= 0) return;
    if (!_editedCustomerIds.contains(current.customerId) &&
        !_savedDrafts.containsKey(current.customerId)) {
      return;
    }

    final existing = _savedDrafts[current.customerId];
    if (existing != null && existing.liters == liters) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final draft = await _deliveryRepo.upsertSessionDraft(
      sessionId: _sessionId,
      customerId: current.customerId,
      date: today,
      liters: liters,
      pricePerLiter: current.priceOverride ?? _price,
      deviceId: _deviceId,
    );
    _savedDrafts[current.customerId] = draft;
    _editedCustomerIds.remove(current.customerId);
  }

  Future<void> _handleExitRequest() async {
    if (_phase != _Phase.entry) return;
    final l10n = AppLocalizations.of(context)!;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final hasProgress = _hasSessionProgress;
        return AlertDialog(
          title: Text(l10n.deliveryExitTitle),
          content: Text(
            hasProgress
                ? l10n.deliveryExitWithProgress
                : l10n.deliveryExitWithoutProgress,
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.deliveryExitYes),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.btnCancel),
            ),
          ],
        );
      },
    );

    if (shouldExit != true) return;

    if (_hasSessionProgress) {
      await _saveCurrentForResumeIfNeeded();
    }
    if (mounted) {
      if (_hasSessionProgress) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deliveryProgressSaved),
          ),
        );
      }
      context.pop();
    }
  }

  Future<void> _saveAndExit() async {
    if (_phase != _Phase.entry) return;

    if (_hasSessionProgress) {
      await _saveCurrentForResumeIfNeeded();
    }
    if (!mounted) return;

    if (_hasSessionProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deliveryProgressSaved),
        ),
      );
    }
    context.pop();
  }

  Future<void> _finishSessionEarly() async {
    if (_phase != _Phase.entry) return;
    final l10n = AppLocalizations.of(context)!;

    await _saveCurrentForResumeIfNeeded();
    if (_savedDrafts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deliveryNeedOneBeforeFinish),
        ),
      );
      return;
    }

    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deliveryFinishNowTitle),
        content: Text(
          l10n.deliveryFinishNowBody,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deliveryFinishAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.btnCancel),
          ),
        ],
      ),
    );

    if (shouldFinish != true) return;
    await _doSaveAll();
  }

  bool _isCurrentCustomerRecorded(Customer customer) =>
      _savedDrafts.containsKey(customer.customerId);

  bool _isCurrentCustomerSkipped(Customer customer) =>
      _skippedCustomerIds.contains(customer.customerId);

  bool _isCurrentCustomerPending(Customer customer) {
    final raw = (_numpadValues[customer.customerId] ?? '').trim();
    final liters = double.tryParse(raw);
    return liters != null &&
        liters > 0 &&
        !_isCurrentCustomerRecorded(customer);
  }

  String _statusLabelFor(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    if (_isCurrentCustomerRecorded(customer))
      return l10n.deliveryStatusRecorded;
    if (_isCurrentCustomerSkipped(customer)) return l10n.deliveryStatusSkipped;
    if (_isCurrentCustomerPending(customer)) return l10n.deliveryStatusReady;
    return l10n.deliveryStatusNotRecorded;
  }

  Color _statusColorFor(Customer customer) {
    if (_isCurrentCustomerRecorded(customer)) return kGreen;
    if (_isCurrentCustomerSkipped(customer)) return kAmber;
    if (_isCurrentCustomerPending(customer)) return kMittiBrown;
    return kMutedGray;
  }

  IconData _statusIconFor(Customer customer) {
    if (_isCurrentCustomerRecorded(customer)) return Icons.check_circle;
    if (_isCurrentCustomerSkipped(customer)) return Icons.remove_circle_outline;
    if (_isCurrentCustomerPending(customer)) return Icons.edit_note;
    return Icons.radio_button_unchecked;
  }

  String _confirmLabelFor(Customer customer, bool isLast) {
    final l10n = AppLocalizations.of(context)!;
    if (_isCurrentCustomerRecorded(customer)) {
      return isLast ? l10n.deliveryUpdateFinalEntry : l10n.deliveryUpdateEntry;
    }
    return isLast ? l10n.deliveryConfirmFinalEntry : l10n.deliveryConfirmEntry;
  }

  String _skipLabelFor(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    return _isCurrentCustomerSkipped(customer)
        ? l10n.deliverySkippedLabel
        : l10n.deliverySkipLabel;
  }

  String _clearLabelFor(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    return _isCurrentCustomerRecorded(customer)
        ? l10n.deliveryClearRecordedEntry
        : l10n.deliveryClearEntry;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static String _litersStr(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _scrollAvatarTo(int index) {
    if (!_avatarScroll.hasClients) return;
    const itemWidth = 60.0; // avatar 40dp + padding + gap
    final target =
        (index * itemWidth).clamp(0.0, _avatarScroll.position.maxScrollExtent);
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isSuccess) {
          context.go('/home');
          return;
        }
        if (_phase == _Phase.entry) {
          await _handleExitRequest();
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
                  onPressed: _handleExitRequest,
                ),
                actions: [
                  IconButton(
                    onPressed: _saveAndExit,
                    tooltip:
                        AppLocalizations.of(context)!.deliverySaveExitAction,
                    icon: const Icon(Icons.save_alt, color: kGreen),
                  ),
                  TextButton.icon(
                    onPressed:
                        (_savedDrafts.isNotEmpty || _hasUnsavedCurrentValue)
                            ? _finishSessionEarly
                            : null,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(
                        AppLocalizations.of(context)!.deliveryFinishAction),
                    style: TextButton.styleFrom(
                      foregroundColor: kGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              )
            : null,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _Phase.loading ||
      _Phase.recovery ||
      _Phase.saving =>
        const Center(child: CircularProgressIndicator(color: kGreen)),
      _Phase.empty =>
        _EmptyState(onAddCustomer: () => context.go('/customers/new')),
      _Phase.success => _SuccessScreen(
          drafts: _successDrafts,
          onDone: () => context.go('/home'),
          onPayment: () {
            context.push('/payment/entry', extra: _successPaymentCustomerId);
          },
        ),
      _Phase.entry => _buildEntryBody(),
    };
  }

  Widget _buildEntryBody() {
    final c = _customers[_currentIndex];
    final hasNext = _currentIndex < _customers.length - 1;
    final isLast = !hasNext;

    return Column(
      children: [
        _AvatarStrip(
          customers: _customers,
          currentIndex: _currentIndex,
          confirmedIds: _savedDrafts.keys.toSet(),
          skippedIds: _skippedCustomerIds,
          scrollController: _avatarScroll,
          onTapCustomer: _jumpToCustomer,
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
                statusLabel: _statusLabelFor(c),
                statusColor: _statusColorFor(c),
                statusIcon: _statusIconFor(c),
                clearLabel: _clearLabelFor(c),
                skipLabel: _skipLabelFor(c),
                confirmLabel: _confirmLabelFor(c, isLast),
                onNumpadChanged: (v) => setState(() {
                  _numpadValues[c.customerId] = v;
                  _skippedCustomerIds.remove(c.customerId);
                  _editedCustomerIds.add(c.customerId);
                }),
                onQtyChip: (q) => setState(() {
                  _numpadValues[c.customerId] = _litersStr(q);
                  _skippedCustomerIds.remove(c.customerId);
                  _editedCustomerIds.add(c.customerId);
                }),
                onClear: _clearCurrentEntry,
                onSkip: _skipCurrent,
                onConfirm: _confirmCurrent,
                onPrevious: _currentIndex > 0 ? _goPrevious : null,
              ),
              // Next card: Offstage — pre-renders widget tree without painting.
              // Triggers Noto Nastalikh font shaping (8–15 ms on Helio G25)
              // before the transition animation begins.
              if (hasNext)
                Offstage(
                  offstage: true,
                  child: _CustomerEntryCard(
                    key: ValueKey(
                        'pre_${_customers[_currentIndex + 1].customerId}'),
                    customer: _customers[_currentIndex + 1],
                    numpadValue: _numpadValues[
                            _customers[_currentIndex + 1].customerId] ??
                        '',
                    price:
                        _customers[_currentIndex + 1].priceOverride ?? _price,
                    statusLabel: _statusLabelFor(_customers[_currentIndex + 1]),
                    statusColor: _statusColorFor(_customers[_currentIndex + 1]),
                    statusIcon: _statusIconFor(_customers[_currentIndex + 1]),
                    clearLabel: _clearLabelFor(_customers[_currentIndex + 1]),
                    skipLabel: _skipLabelFor(_customers[_currentIndex + 1]),
                    confirmLabel: _confirmLabelFor(
                      _customers[_currentIndex + 1],
                      _currentIndex + 1 == _customers.length - 1,
                    ),
                    onNumpadChanged: (_) {},
                    onQtyChip: (_) {},
                    onClear: null,
                    onSkip: null,
                    onConfirm: () {},
                    onPrevious: null,
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
  final Set<String> skippedIds;
  final ScrollController scrollController;
  final ValueChanged<int> onTapCustomer;

  const _AvatarStrip({
    required this.customers,
    required this.currentIndex,
    required this.confirmedIds,
    required this.skippedIds,
    required this.scrollController,
    required this.onTapCustomer,
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
          final c = customers[i];
          final isCurrent = i == currentIndex;
          final isDone = confirmedIds.contains(c.customerId);
          final isSkipped = skippedIds.contains(c.customerId);
          final initial =
              c.name.trim().isNotEmpty ? c.name.trim()[0].toUpperCase() : '?';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onTapCustomer(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? kGreen
                      : isDone
                          ? kGreen.withValues(alpha: 0.15)
                          : kSurfaceGray,
                  border: isCurrent
                      ? Border.all(color: kGreenDark, width: 2)
                      : null,
                ),
                child: isDone && !isCurrent
                    ? const Icon(Icons.check, color: kGreen, size: 18)
                    : isSkipped && !isCurrent
                        ? const Icon(Icons.remove, color: kAmber, size: 18)
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
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final String clearLabel;
  final String skipLabel;
  final String confirmLabel;
  final ValueChanged<String> onNumpadChanged;
  final ValueChanged<double> onQtyChip;
  final VoidCallback? onClear;
  final VoidCallback? onSkip;
  final VoidCallback onConfirm;
  final VoidCallback? onPrevious;

  const _CustomerEntryCard({
    super.key,
    required this.customer,
    required this.numpadValue,
    required this.price,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.clearLabel,
    required this.skipLabel,
    required this.confirmLabel,
    required this.onNumpadChanged,
    required this.onQtyChip,
    required this.onClear,
    required this.onSkip,
    required this.onConfirm,
    required this.onPrevious,
  });

  double? get _liters => double.tryParse(numpadValue);
  double get _total => ((_liters ?? 0) * price * 100).round() / 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: kBodyStyle.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Quantity chips ─────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.deliveryQuantityLabel,
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
                  numpadValue.isEmpty
                      ? l10n.deliveryLitersZero
                      : l10n.deliveryLitersValue(numpadValue),
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
                        l10n.deliveryPricePerLiter(price.toStringAsFixed(0)),
                        style: kBodyStyle.copyWith(color: kMutedGray),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Custom numpad — system keyboard never shown for numbers ────────
          NumpadWidget(value: numpadValue, onChanged: onNumpadChanged),
          const SizedBox(height: 16),

          if (onClear != null) ...[
            SizedBox(
              height: kButtonHeight,
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAlertRed,
                  side: const BorderSide(color: kAlertRed, width: 1.2),
                ),
                onPressed: onClear,
                child: Text(clearLabel),
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (onSkip != null) ...[
            SizedBox(
              height: kButtonHeight,
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAmber,
                  side: const BorderSide(color: kAmber, width: 1.2),
                ),
                onPressed: onSkip,
                child: Text(skipLabel),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Confirm — kConfirmButtonHeight (72dp) ──────────────────────────
          SizedBox(
            height: kConfirmButtonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              child: Text(
                confirmLabel,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                child: Text(l10n.previousCustomer),
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
    final l10n = AppLocalizations.of(context)!;
    if (balance > 0) {
      return Text(
        l10n.balanceOwed(balance.toStringAsFixed(2)),
        style: kBodyStyle.copyWith(color: kAlertRed),
      );
    } else if (balance < 0) {
      return Text(
        l10n.deliveryAdvance((-balance).toStringAsFixed(2)),
        style: kBodyStyle.copyWith(color: kGreen),
      );
    }
    return Text(
      l10n.balanceClear,
      style: kBodyStyle.copyWith(color: kGreen),
    );
  }
}

// ─── Success screen ───────────────────────────────────────────────────────────

/// Session receipt screen — shown to the customer as proof of delivery.
///
/// NEVER auto-dismisses. User must tap "Done" explicitly.
/// "Record payment" is the primary payment discovery mechanism.
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
    final l10n = AppLocalizations.of(context)!;
    final totalLiters = drafts.fold(0.0, (s, d) => s + d.liters);
    final totalValue = drafts.fold(0.0, (s, d) => s + d.totalValue);
    final today = DateTime.now();
    final dateStr = '${today.day}/${today.month}/${today.year}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            const Icon(Icons.check_circle_outline, color: kWhite, size: 80),
            const SizedBox(height: 20),

            Text(
              l10n.successSaved,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                  _SummaryRow(label: l10n.customers, value: '${drafts.length}'),
                  const SizedBox(height: 14),
                  const Divider(color: kGreen, height: 1),
                  const SizedBox(height: 14),
                  _SummaryRow(
                    label: l10n.reportTotalLiters,
                    value: l10n
                        .deliveryLitersValue(totalLiters.toStringAsFixed(1)),
                  ),
                  const SizedBox(height: 14),
                  _SummaryRow(
                    label: l10n.deliveryTotalValue,
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
                child: Text(
                  l10n.recordPayment,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
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
                child: Text(
                  l10n.btnDone,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64, color: kMutedGray),
            const SizedBox(height: 16),
            Text(
              l10n.noCustomersYet,
              style: const TextStyle(
                fontSize: 20,
                color: kMittiBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstCustomer,
              style: kBodyStyle,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddCustomer,
              child: Text(l10n.btnAddCustomer),
            ),
          ],
        ),
      ),
    );
  }
}
