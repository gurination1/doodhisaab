import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/customer_repository.dart';
import '../../db/db_provider.dart';
import '../../db/payment_repository.dart';
import '../../models/customer.dart';
import '../../models/delivery.dart';
import '../../models/payment.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_theme.dart';

/// Customer profile screen.
///
/// Architecture:
///  - [customerId] passed via path param — never the string 'new'.
///    Router declares /customers/new before /customers/:id to guarantee this.
///  - Data loaded from repos directly (not providers) — profile needs three
///    queries (customer + deliveries + payments) that don't belong in global cache.
///  - Recent deliveries: raw DB query via [DatabaseProvider] (same pattern as
///    StatementRepository). Not in DeliveryRepository because per-customer
///    confirmed-delivery reads are a statement concern, not a session concern.
///  - Balance badge: red = owes money, green = clear, amber = credit.
///  - Archive: confirm dialog → archiveCustomer → invalidate provider → pop.
///  - No bottom nav — this is a push screen above /customers.
class CustomerProfileScreen extends ConsumerStatefulWidget {
  /// Always a real UUID — never 'new'. See router for ordering guarantee.
  final String customerId;

  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  final _customerRepo = CustomerRepository();
  final _paymentRepo  = PaymentRepository();

  bool      _loading   = true;
  String?   _error;
  bool      _archiving = false;

  Customer?      _customer;
  List<Delivery> _recentDeliveries = [];
  List<Payment>  _recentPayments   = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final customer = await _customerRepo.getCustomerById(widget.customerId);
      if (customer == null) {
        setState(() { _error = 'گاہک نہیں ملا'; _loading = false; });
        return;
      }
      final deliveries = await _getRecentConfirmedDeliveries(widget.customerId);
      final payments   = await _paymentRepo.getRecentPayments(
        widget.customerId, limit: 10,
      );
      if (!mounted) return;
      setState(() {
        _customer         = customer;
        _recentDeliveries = deliveries;
        _recentPayments   = payments;
        _loading          = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  /// Last 10 confirmed deliveries for this customer, newest first.
  ///
  /// Uses [DatabaseProvider] directly — same pattern as StatementRepository.
  /// DeliveryRepository only exposes session-scoped write operations.
  Future<List<Delivery>> _getRecentConfirmedDeliveries(
      String customerId) async {
    final db   = await DatabaseProvider.database;
    final rows = await db.query(
      'deliveries',
      where:     "customer_id = ? AND status = 'confirmed'",
      whereArgs: [customerId],
      orderBy:   'date DESC',
      limit:     10,
    );
    return rows.map(Delivery.fromMap).toList();
  }

  // ── Archive ────────────────────────────────────────────────────────────────

  Future<void> _confirmArchive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('گاہک ہٹائیں؟'),
        content: Text(
          '${_customer!.name} کو آرکائیو کر دیا جائے گا۔\n'
          'پرانا ریکارڈ محفوظ رہے گا۔',
          style: kBodyLgUrduStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: kMutedGray),
            child: const Text('منسوخ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kAlertRed),
            child: const Text('ہٹائیں',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _archiving = true);
    try {
      await _customerRepo.archiveCustomer(widget.customerId);
      ref.invalidate(activeCustomersProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _archiving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: CircularProgressIndicator(color: kGreen)),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: kAlertRed, size: 48),
                const SizedBox(height: 12),
                Text(_error!, style: kBodyStyle, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('دوبارہ کوشش'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final c = _customer!;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'ترمیم',
            onPressed: () async {
              await context.push('/customers/new', extra: c);
              _load(); // Reload after edit
            },
          ),
          _archiving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kWhite),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'آرکائیو',
                  onPressed: _confirmArchive,
                ),
        ],
      ),
      body: RefreshIndicator(
        color: kGreen,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── Balance hero card ────────────────────────────────────────
            _BalanceCard(
              customer: c,
              onPayment: () async {
                await context.push('/payment/entry', extra: c.customerId);
                _load();
              },
            ),

            const SizedBox(height: 8),

            // ── Details card ─────────────────────────────────────────────
            _DetailsCard(customer: c),

            // ── Recent deliveries ────────────────────────────────────────
            _SectionHeader(
              title: 'حالیہ ڈیری',
              onViewAll: () =>
                  context.push('/reports/statement/${c.customerId}'),
            ),
            if (_recentDeliveries.isEmpty)
              const _EmptySection(message: 'کوئی تصدیق شدہ ڈیری نہیں')
            else
              ..._recentDeliveries.map((d) => _DeliveryTile(delivery: d)),

            const SizedBox(height: 4),

            // ── Recent payments ──────────────────────────────────────────
            const _SectionHeader(title: 'حالیہ ادائیگیاں'),
            if (_recentPayments.isEmpty)
              const _EmptySection(message: 'کوئی ادائیگی نہیں')
            else
              ..._recentPayments.map((p) => _PaymentTile(payment: p)),
          ],
        ),
      ),
    );
  }
}

// ─── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onPayment;

  const _BalanceCard({required this.customer, required this.onPayment});

  @override
  Widget build(BuildContext context) {
    final b = customer.cachedBalance;

    final Color bg;
    final String amountText;
    final String statusText;

    if (b > 0.01) {
      bg         = kAlertRed;
      amountText = '₨ ${_fmt(b)}';
      statusText = 'واجب الادا';
    } else if (b < -0.01) {
      bg         = kAmber;
      amountText = '+ ₨ ${_fmt(b.abs())}';
      statusText = 'ایڈوانس ادائیگی';
    } else {
      bg         = kGreen;
      amountText = 'صاف';
      statusText = 'کوئی بقایا نہیں';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بقایا رقم',
                    style:
                        kCaptionStyle.copyWith(color: kWhite.withOpacity(0.8))),
                const SizedBox(height: 6),
                Text(
                  amountText,
                  style: kDisplayStyle.copyWith(color: kWhite, fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: kBodyStyle.copyWith(
                    color: kWhite.withOpacity(0.85),
                    fontFamily: 'NotoNastaliqUrdu',
                  ),
                ),
              ],
            ),
          ),
          if (b > 0.01)
            ElevatedButton(
              onPressed: onPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: kWhite,
                foregroundColor: bg,
                minimumSize: const Size(100, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoNastaliqUrdu',
                ),
              ),
              child: const Text('ادائیگی'),
            ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final rounded = (v * 100).round() / 100;
    return rounded % 1 == 0
        ? '${rounded.toInt()}'
        : rounded.toStringAsFixed(2);
  }
}

// ─── Details card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final Customer customer;
  const _DetailsCard({required this.customer});

  String _cycleLabel() {
    return switch (customer.paymentCycle) {
      'Weekly'   => 'ہفتہ وار',
      'BiWeekly' => 'دو ہفتہ وار',
      'Monthly'  => 'ماہانہ',
      'Custom'   => '${customer.paymentCycleDays ?? '?'} دن',
      _          => customer.paymentCycle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final litersLabel = c.defaultLiters % 1 == 0
        ? '${c.defaultLiters.toInt()} لیٹر'
        : '${c.defaultLiters.toStringAsFixed(1)} لیٹر';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.water_drop_outlined,
              label: 'روزانہ دودھ',
              value: litersLabel,
            ),
            const Divider(height: 20),
            _DetailRow(
              icon: Icons.repeat,
              label: 'ادائیگی سائیکل',
              value: _cycleLabel(),
            ),
            if (c.phone != null) ...[
              const Divider(height: 20),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'فون',
                value: c.phone!,
              ),
            ],
            if (c.address != null) ...[
              const Divider(height: 20),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'پتہ',
                value: c.address!,
              ),
            ],
            if (c.priceOverride != null) ...[
              const Divider(height: 20),
              _DetailRow(
                icon: Icons.price_change_outlined,
                label: 'خصوصی قیمت',
                value: '₨ ${c.priceOverride!.toStringAsFixed(2)} فی لیٹر',
                valueColor: kAmber,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kMutedGray),
        const SizedBox(width: 10),
        Text(label, style: kCaptionStyle),
        const Spacer(),
        Text(
          value,
          style: kBodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? kInkBlack,
          ),
        ),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: kTitleStyle.copyWith(fontSize: 18)),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(foregroundColor: kGreen),
              child: const Text('سب دیکھیں',
                  style: TextStyle(fontFamily: 'NotoNastaliqUrdu')),
            ),
        ],
      ),
    );
  }
}

// ─── Tiles ────────────────────────────────────────────────────────────────────

class _DeliveryTile extends StatelessWidget {
  final Delivery delivery;
  const _DeliveryTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final liters = delivery.liters;
    final litersText = liters % 1 == 0
        ? '${liters.toInt()} لیٹر'
        : '${liters.toStringAsFixed(1)} لیٹر';
    final total = delivery.totalValue;
    final totalText = total % 1 == 0
        ? '₨ ${total.toInt()}'
        : '₨ ${total.toStringAsFixed(2)}';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(Icons.water_drop_outlined, color: kGreen, size: 20),
      title: Text(litersText, style: kBodyStyle),
      subtitle: Text(delivery.date, style: kCaptionStyle),
      trailing: Text(
        totalText,
        style: kBodyStyle.copyWith(
            color: kGreen, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Payment payment;
  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final amt = payment.amount;
    final amtText = amt % 1 == 0 ? '₨ ${amt.toInt()}' : '₨ ${amt.toStringAsFixed(2)}';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(Icons.payments_outlined, color: kAmber, size: 20),
      title: Text(amtText,
          style: kBodyStyle.copyWith(
              color: kGreen, fontWeight: FontWeight.w600)),
      subtitle: Text(payment.date, style: kCaptionStyle),
      trailing: payment.note != null
          ? Text(payment.note!,
              style: kCaptionStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(message, style: kBodyStyle.copyWith(color: kMutedGray)),
    );
  }
}
