import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/customer_repository.dart';
import '../../db/payment_repository.dart';
import '../../db/settings_repository.dart';
import '../../models/customer.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Payment entry screen.
///
/// Architecture:
///  - Write-on-save: a single INSERT + adjustCachedBalance(-amount) on tap.
///    No draft state. No session. One payment per save.
///  - Avatar strip: horizontal, single-select. Tap any avatar to switch customer.
///    No "confirmed" state — just selected vs unselected.
///  - Numpad: same custom NumpadWidget as delivery. System keyboard never shown
///    for the amount field (readOnly: true on the display container).
///  - Note field: plain TextField with system keyboard (text, not number).
///  - Overpayment: amber warning when amount > cachedBalance. Save is still
///    allowed — farmer may pay in advance.
///  - Pre-selection: if navigated from a customer profile or from _SuccessScreen,
///    [customerId] is passed via GoRouter extra. That customer is pre-selected.
///  - After save: adjustCachedBalance → invalidate todayDeliveries → SnackBar → pop.
///  - No payment edit/delete in MVP.
class PaymentEntryScreen extends ConsumerStatefulWidget {
  /// Customer to pre-select. Null when opened from the global payments button.
  final String? customerId;

  const PaymentEntryScreen({super.key, this.customerId});

  @override
  ConsumerState<PaymentEntryScreen> createState() => _PaymentEntryState();
}

class _PaymentEntryState extends ConsumerState<PaymentEntryScreen> {
  // ── Load state ──────────────────────────────────────────────────────────────
  bool _loading = true;

  // ── Data ────────────────────────────────────────────────────────────────────
  List<Customer> _customers = [];
  String _deviceId = '';

  // ── Entry state ──────────────────────────────────────────────────────────────
  String? _selectedCustomerId;
  String _numpadValue = '';
  bool _saving = false;

  // ── Note ────────────────────────────────────────────────────────────────────
  final _noteController = TextEditingController();

  // ── Scroll ──────────────────────────────────────────────────────────────────
  final _avatarScroll = ScrollController();

  final _paymentRepo  = PaymentRepository();
  final _customerRepo = CustomerRepository();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _avatarScroll.dispose();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    final customers = await _customerRepo.getActiveCustomers();
    final deviceId  = await SettingsRepository.instance.getDeviceId();
    if (!mounted) return;

    // Determine which customer to pre-select
    String? preselect;
    if (widget.customerId != null) {
      // Verify it exists in the active list (customer could have been archived)
      final exists = customers.any((c) => c.customerId == widget.customerId);
      if (exists) preselect = widget.customerId;
    }

    setState(() {
      _customers          = customers;
      _deviceId           = deviceId;
      _selectedCustomerId = preselect ?? (customers.isNotEmpty ? null : null);
      _loading            = false;
    });

    // Scroll avatar strip to pre-selected customer
    if (preselect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = _customers.indexWhere((c) => c.customerId == preselect);
        if (index >= 0) _scrollAvatarTo(index);
      });
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────────

  Future<void> _doSave() async {
    final customer = _selectedCustomer;
    if (customer == null) return;

    final amount = double.tryParse(_numpadValue);
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 1. Persist payment row
    await _paymentRepo.insertPayment(
      customerId: customer.customerId,
      date:       today,
      amount:     amount,
      deviceId:   _deviceId,
      note:       _noteController.text.trim().isEmpty
                    ? null
                    : _noteController.text.trim(),
    );

    // 2. Decrement cached_balance — payments reduce what the customer owes
    await _customerRepo.adjustCachedBalance(customer.customerId, -amount);

    // 3. Refresh providers so home screen balance reflects the change
    ref.invalidate(todayDeliveriesProvider);

    if (!mounted) return;
    setState(() => _saving = false);

    // 4. Feedback + pop
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${customer.name} — ₹${amount.toStringAsFixed(2)} محفوظ',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: kGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Customer? get _selectedCustomer {
    if (_selectedCustomerId == null) return null;
    try {
      return _customers.firstWhere((c) => c.customerId == _selectedCustomerId);
    } catch (_) {
      return null;
    }
  }

  double? get _amount => double.tryParse(_numpadValue);

  bool get _canSave =>
      !_saving &&
      _selectedCustomerId != null &&
      _amount != null &&
      _amount! > 0;

  bool get _isOverpayment {
    final c = _selectedCustomer;
    final a = _amount;
    if (c == null || a == null) return false;
    return a > c.cachedBalance && c.cachedBalance > 0;
  }

  void _scrollAvatarTo(int index) {
    if (!_avatarScroll.hasClients) return;
    const itemWidth = 60.0;
    final target = (index * itemWidth)
        .clamp(0.0, _avatarScroll.position.maxScrollExtent);
    _avatarScroll.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _selectCustomer(String customerId, int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCustomerId = customerId);
    _scrollAvatarTo(index);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ادائیگی درج کریں',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: kInkBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _customers.isEmpty
              ? const _EmptyCustomersState()
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // ── Avatar strip — single-select ─────────────────────────────────────
        _AvatarStrip(
          customers:          _customers,
          selectedId:         _selectedCustomerId,
          scrollController:   _avatarScroll,
          onSelect:           _selectCustomer,
        ),
        const Divider(height: 1, color: kSurfaceGray),

        // ── Entry form ───────────────────────────────────────────────────────
        Expanded(
          child: _saving
              ? const Center(child: CircularProgressIndicator(color: kGreen))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── Selected customer header ──────────────────────────
                      if (_selectedCustomer != null) ...[
                        _CustomerHeader(customer: _selectedCustomer!),
                        const SizedBox(height: 20),
                      ] else ...[
                        _SelectPrompt(),
                        const SizedBox(height: 20),
                      ],

                      // ── Amount label ──────────────────────────────────────
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'رقم (روپے)',
                          textDirection: TextDirection.rtl,
                          style: kLabelStyle,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Amount display — read-only, numpad provides input ─
                      _AmountDisplay(
                        numpadValue: _numpadValue,
                        customer: _selectedCustomer,
                      ),
                      const SizedBox(height: 16),

                      // ── Overpayment warning ───────────────────────────────
                      if (_isOverpayment) ...[
                        _OverpaymentWarning(
                          balance:  _selectedCustomer!.cachedBalance,
                          amount:   _amount!,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Custom numpad ─────────────────────────────────────
                      NumpadWidget(
                        value: _numpadValue,
                        onChanged: (v) => setState(() => _numpadValue = v),
                      ),
                      const SizedBox(height: 20),

                      // ── Note field — system keyboard (text, not number) ───
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'نوٹ (اختیاری)',
                          textDirection: TextDirection.rtl,
                          style: kLabelStyle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _NoteField(controller: _noteController),
                      const SizedBox(height: 24),

                      // ── Save button (72dp) — disabled when invalid ────────
                      SizedBox(
                        height: kConfirmButtonHeight,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canSave ? _doSave : null,
                          child: const Text(
                            'محفوظ کریں',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Avatar strip ─────────────────────────────────────────────────────────────

/// Horizontal avatar strip — single-select (tap to switch customer).
///
/// No "confirmed" concept — unlike the delivery flow, payment is one customer
/// per save. Tap highlights the selected customer.
class _AvatarStrip extends StatelessWidget {
  final List<Customer> customers;
  final String? selectedId;
  final ScrollController scrollController;
  final void Function(String customerId, int index) onSelect;

  const _AvatarStrip({
    required this.customers,
    required this.selectedId,
    required this.scrollController,
    required this.onSelect,
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
          final c          = customers[i];
          final isSelected = c.customerId == selectedId;
          final initial    = c.name.trim().isNotEmpty
              ? c.name.trim()[0].toUpperCase()
              : '?';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(c.customerId, i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? kGreen : kSurfaceGray,
                  border: isSelected
                      ? Border.all(color: kGreenDark, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? kWhite : kMittiBrown,
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

// ─── Customer header ──────────────────────────────────────────────────────────

class _CustomerHeader extends StatelessWidget {
  final Customer customer;
  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Row(
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

// ─── Select prompt ────────────────────────────────────────────────────────────

class _SelectPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kInputHeight,
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kMutedGray),
      ),
      child: const Center(
        child: Text(
          'اوپر سے گاہک منتخب کریں',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: kMutedGray, fontSize: 16),
        ),
      ),
    );
  }
}

// ─── Amount display ───────────────────────────────────────────────────────────

/// Read-only amount display box — NumpadWidget provides all input.
/// System keyboard MUST NOT appear here. No TextField used here.
class _AmountDisplay extends StatelessWidget {
  final String numpadValue;
  final Customer? customer;

  const _AmountDisplay({required this.numpadValue, required this.customer});

  @override
  Widget build(BuildContext context) {
    final amount  = double.tryParse(numpadValue);
    final balance = customer?.cachedBalance;
    final hasValue = numpadValue.isNotEmpty && amount != null && amount > 0;

    return Container(
      height: kInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasValue ? kGreen : kMutedGray,
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: balance hint
          if (balance != null && balance > 0 && !hasValue)
            Text(
              'باقی: ₹${balance.toStringAsFixed(0)}',
              style: kBodyStyle.copyWith(color: kMutedGray),
            )
          else
            const SizedBox.shrink(),

          // Right side: entered amount (RTL — amount is on the right)
          Text(
            numpadValue.isEmpty ? '0 روپے' : '₹$numpadValue',
            style: kTitleStyle.copyWith(
              color: numpadValue.isEmpty ? kMutedGray : kInkBlack,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overpayment warning ──────────────────────────────────────────────────────

class _OverpaymentWarning extends StatelessWidget {
  final double balance;
  final double amount;

  const _OverpaymentWarning({required this.balance, required this.amount});

  @override
  Widget build(BuildContext context) {
    final extra = ((amount - balance) * 100).round() / 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAmber, width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(Icons.warning_amber, color: kAmber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'رقم باقی سے ₹${extra.toStringAsFixed(2)} زیادہ ہے',
              textDirection: TextDirection.rtl,
              style: kBodyStyle.copyWith(color: kAmber),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note field ───────────────────────────────────────────────────────────────

/// Plain text note field — system keyboard (not numpad).
/// Single-line, RTL alignment. Optional.
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kInputHeight,
      child: TextField(
        controller:  controller,
        maxLines:    1,
        textAlign:   TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 16, color: kInkBlack),
        decoration: InputDecoration(
          hintText:       'مثال: عید ادائیگی',
          hintStyle:      TextStyle(color: kMutedGray, fontSize: 16),
          hintTextDirection: TextDirection.rtl,
          filled:         true,
          fillColor:      kWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kMutedGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kMutedGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kGreen, width: 2),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCustomersState extends StatelessWidget {
  const _EmptyCustomersState();

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
            SizedBox(
              height: kButtonHeight,
              child: ElevatedButton(
                onPressed: () => context.go('/customers/new'),
                child: const Text(
                  'گاہک شامل کریں',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
