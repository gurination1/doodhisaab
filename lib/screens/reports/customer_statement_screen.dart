import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/services/analytics_service.dart';
import '../../db/customer_repository.dart';
import '../../db/statement_repository.dart';
import '../../models/customer.dart';
import '../../models/customer_statement.dart';
import '../../models/delivery.dart';
import '../../models/payment.dart';
import '../../theme/app_theme.dart';

/// Monthly statement detail for one customer.
///
/// Navigation: pushed via context.push('/reports/statement/:id')
/// from the Customer Statements tab in ReportsScreen.
///
/// Has its own month picker — defaults to current month.
/// FutureBuilder keyed on (customerId, year, month) so it rebuilds correctly.
///
/// ⚠️  All DB calls on the main isolate via FutureBuilder.
/// Never use Isolate.run() — sqflite MethodChannel is main-isolate only.
class CustomerStatementScreen extends StatefulWidget {
  final String customerId;
  const CustomerStatementScreen({super.key, required this.customerId});

  @override
  State<CustomerStatementScreen> createState() =>
      _CustomerStatementScreenState();
}

class _CustomerStatementScreenState extends State<CustomerStatementScreen> {
  late int _year;
  late int _month;
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadCustomer();
    unawaited(
      AnalyticsService.instance.trackFeatureUsed(
        featureName: 'customer_statement_view',
        screenName: 'Customer Statement',
        routeName: '/reports/statement/${widget.customerId}',
        customerId: widget.customerId,
      ),
    );
  }

  Future<void> _loadCustomer() async {
    final c = await CustomerRepository().getCustomerById(widget.customerId);
    if (mounted) setState(() => _customer = c);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _year == now.year && _month == now.month;
  }

  void _prevMonth() {
    AnalyticsService.instance.trackButtonClicked(
      buttonName: 'view_previous_month',
      screenName: 'Customer Statement',
      routeName: '/reports/statement/${widget.customerId}',
      elementType: 'icon_button',
      elementText: 'Previous Month',
    );
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    AnalyticsService.instance.trackButtonClicked(
      buttonName: 'view_next_month',
      screenName: 'Customer Statement',
      routeName: '/reports/statement/${widget.customerId}',
      elementType: 'icon_button',
      elementText: 'Next Month',
    );
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerName = _customer?.name ?? '...';

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: kWhite,
        title: Text(customerName),
        actions: [
          // Payment shortcut — navigate to payment entry pre-selecting this customer
          if (_customer != null)
            IconButton(
              icon: const Icon(Icons.payments_outlined),
              tooltip: 'Payment',
              onPressed: () {
                AnalyticsService.instance.trackButtonClicked(
                  buttonName: 'record_payment',
                  screenName: 'Customer Statement',
                  routeName: '/reports/statement/${widget.customerId}',
                  elementType: 'icon_button',
                  elementText: 'Payment',
                );
                context.push('/payment/entry', extra: widget.customerId);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Month picker bar
          Container(
            color: kSurfaceGray,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _isCurrentMonth ? kMutedGray : kInkBlack,
                  onPressed: _isCurrentMonth ? null : _nextMonth,
                ),
                Text(
                  intl.DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kInkBlack,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: kInkBlack,
                  onPressed: _prevMonth,
                ),
              ],
            ),
          ),
          // Statement content
          Expanded(
            child: FutureBuilder<CustomerStatement>(
              key: ValueKey('stmt-${widget.customerId}-$_year-$_month'),
              future: StatementRepository()
                  .getCustomerStatement(widget.customerId, _year, _month),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const _StatementSkeleton();
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: const TextStyle(color: kAlertRed, fontSize: 14),
                    ),
                  );
                }
                return _StatementContent(statement: snap.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Statement Content ────────────────────────────────────────────────────────

class _StatementContent extends StatelessWidget {
  final CustomerStatement statement;
  const _StatementContent({required this.statement});

  @override
  Widget build(BuildContext context) {
    final isEmpty = statement.deliveries.isEmpty && statement.payments.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card — always visible
        _SummaryCard(statement: statement),
        const SizedBox(height: 16),

        // Deliveries list
        if (statement.deliveries.isNotEmpty) ...[
          _SectionHeader(label: 'Deliveries (${statement.deliveries.length})'),
          ...statement.deliveries.map((d) => _DeliveryRow(d)),
          const SizedBox(height: 16),
        ],

        // Payments list
        if (statement.payments.isNotEmpty) ...[
          _SectionHeader(label: 'Payments (${statement.payments.length})'),
          ...statement.payments.map((p) => _PaymentRow(p)),
          const SizedBox(height: 16),
        ],

        // Empty state
        if (isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                'No records for this month',
                style: const TextStyle(color: kMutedGray, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final CustomerStatement statement;
  const _SummaryCard({required this.statement});

  @override
  Widget build(BuildContext context) {
    final Color balanceColor;
    final String balanceLabel;
    if (statement.isSettled) {
      balanceColor = kGreen;
      balanceLabel = 'Settled';
    } else if (statement.hasBalance) {
      balanceColor = kAlertRed;
      balanceLabel = 'Due: ₹${statement.balance.toStringAsFixed(0)}';
    } else {
      balanceColor = kGreen;
      balanceLabel = 'Advance: ₹${statement.balance.abs().toStringAsFixed(0)}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Total Liters',
              value: '${statement.totalLiters.toStringAsFixed(1)} L'),
          _SummaryRow(
              label: 'Total Value',
              value: '₹${statement.totalValue.toStringAsFixed(0)}'),
          _SummaryRow(
              label: 'Paid',
              value: '₹${statement.totalPaid.toStringAsFixed(0)}'),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                    color: kInkBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              Text(
                balanceLabel,
                style: TextStyle(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kMutedGray, fontSize: 14)),
            Text(value,
                style: const TextStyle(
                    color: kInkBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
              color: kMittiBrown, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );
}

// ─── Delivery Row ─────────────────────────────────────────────────────────────

class _DeliveryRow extends StatelessWidget {
  final Delivery delivery;
  const _DeliveryRow(this.delivery);

  @override
  Widget build(BuildContext context) {
    // Show MM-DD from ISO date
    final date = delivery.date.length >= 10
        ? delivery.date.substring(5, 10)
        : delivery.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(date, style: const TextStyle(color: kMutedGray, fontSize: 13)),
          const Spacer(),
          Text(
            '${delivery.liters.toStringAsFixed(1)} L',
            style: const TextStyle(color: kInkBlack, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Text(
            '₹${delivery.totalValue.toStringAsFixed(0)}',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                color: kGreen, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Row ──────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  const _PaymentRow(this.payment);

  @override
  Widget build(BuildContext context) {
    final date = payment.date.length >= 10
        ? payment.date.substring(5, 10)
        : payment.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(date, style: const TextStyle(color: kMutedGray, fontSize: 13)),
          const Spacer(),
          if (payment.note != null && payment.note!.isNotEmpty)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  payment.note!,
                  style: const TextStyle(color: kMutedGray, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          Text(
            '₹${payment.amount.toStringAsFixed(0)}',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                color: kMittiBrown, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _StatementSkeleton extends StatelessWidget {
  const _StatementSkeleton();

  Widget _box(double width, double height) => Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            color: kSurfaceGray, borderRadius: BorderRadius.circular(4)),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Summary card skeleton
            Container(
              height: 120,
              decoration: BoxDecoration(
                  color: kSurfaceGray, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 24),
            _box(100, 14),
            _box(double.infinity, 40),
            _box(double.infinity, 40),
            _box(double.infinity, 40),
          ],
        ),
      );
}
