import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/services/analytics_service.dart';
import '../../db/customer_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../models/monthly_summary.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_exit_guard.dart';

/// Reports screen — two tabs:
///  Tab 0 "Customer Statements" — active customers with cached balance; tap → statement detail
///  Tab 1 "Profit & Loss"       — monthly P&L summary with month picker
///
/// ⚠️  Architecture: ALL DB calls run inside FutureBuilder on the MAIN ISOLATE.
/// sqflite's MethodChannel is bound to the main isolate.
/// Never use Isolate.run() here — it will throw at runtime.
///
/// Performance (Step 24):
///  - Customer list uses ListView.builder + itemExtent: kListRowHeight.
///  - _CustomerBalanceTile draws its own bottom border — no separatorBuilder.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    unawaited(
      AnalyticsService.instance.trackFeatureUsed(
        featureName: 'reports_view',
        screenName: 'Reports',
        routeName: '/reports',
      ),
    );
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tabLabel = _tabController.index == 0 ? 'Statements' : 'Profit & Loss';
    AnalyticsService.instance.trackButtonClicked(
      buttonName: _tabController.index == 0
          ? 'open_customer_statements_tab'
          : 'open_profit_loss_tab',
      screenName: 'Reports',
      routeName: '/reports',
      elementType: 'tab',
      elementText: tabLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppExitGuard(
      child: Scaffold(
        backgroundColor: kCream,
        appBar: AppBar(
          backgroundColor: kGreen,
          foregroundColor: kWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(l10n.navReports),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: kWhite,
            labelColor: kWhite,
            // ignore: deprecated_member_use
            unselectedLabelColor: kWhite.withOpacity(0.65),
            tabs: [
              Tab(text: l10n.reportTabStatements),
              Tab(text: l10n.reportTabPL),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _StatementsTab(),
            _ProfitLossTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Statements Tab ──────────────────────────────────────────────────

class _StatementsTab extends StatelessWidget {
  const _StatementsTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Customer>>(
      future: CustomerRepository().getActiveCustomers(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _StatementListSkeleton();
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: kAlertRed, fontSize: 14),
            ),
          );
        }
        final customers = snap.data ?? [];
        if (customers.isEmpty) {
          return const Center(
            child: Text(
              'No customers',
              style: TextStyle(color: kMutedGray, fontSize: 16),
            ),
          );
        }
        // Performance: itemExtent eliminates per-item layout measurement.
        // _CustomerBalanceTile draws its own bottom border.
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: customers.length,
          itemExtent: kListRowHeight,
          itemBuilder: (context, i) => _CustomerBalanceTile(customers[i]),
        );
      },
    );
  }
}

class _CustomerBalanceTile extends StatelessWidget {
  final Customer customer;
  const _CustomerBalanceTile(this.customer);

  @override
  Widget build(BuildContext context) {
    final balance = customer.cachedBalance;
    final balanceStr = balance.abs().toStringAsFixed(0);

    final Color balanceColor;
    final String balanceLabel;
    if (balance.abs() < 0.01) {
      balanceColor = kGreen;
      balanceLabel = 'Clear';
    } else if (balance > 0) {
      balanceColor = kAlertRed;
      balanceLabel = '₹$balanceStr due';
    } else {
      balanceColor = kGreen;
      balanceLabel = '₹$balanceStr advance';
    }

    return Material(
      color: kCream,
      child: InkWell(
        onTap: () {
          AnalyticsService.instance.trackButtonClicked(
            buttonName: 'open_customer_statement',
            screenName: 'Reports',
            routeName: '/reports',
            elementType: 'row',
            elementText: customer.name,
          );
          context.push('/reports/statement/${customer.customerId}');
        },
        child: Container(
          height: kListRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: kSurfaceGray, width: 1),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kGreen,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0] : '?',
                  style: const TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer.name,
                  style: const TextStyle(
                    color: kInkBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                balanceLabel,
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: kMutedGray, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── P&L Tab ──────────────────────────────────────────────────────────────────

class _ProfitLossTab extends ConsumerStatefulWidget {
  const _ProfitLossTab();

  @override
  ConsumerState<_ProfitLossTab> createState() => _ProfitLossTabState();
}

class _ProfitLossTabState extends ConsumerState<_ProfitLossTab> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _year == now.year && _month == now.month;
  }

  void _prevMonth() {
    AnalyticsService.instance.trackButtonClicked(
      buttonName: 'view_previous_month',
      screenName: 'Reports',
      routeName: '/reports',
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
      screenName: 'Reports',
      routeName: '/reports',
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
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(monthlySummaryProvider(_year, _month));
    return Column(
      children: [
        // Month picker bar
        Container(
          color: kSurfaceGray,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // chevron_left = advance forward in RTL
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: _isCurrentMonth ? kMutedGray : kInkBlack,
                onPressed: _isCurrentMonth ? null : _nextMonth,
              ),
              Text(
                intl.DateFormat.yMMMM(l10n.localeName).format(
                  DateTime(_year, _month),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kInkBlack,
                ),
              ),
              // chevron_right = go back in RTL
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: kInkBlack,
                onPressed: _prevMonth,
              ),
            ],
          ),
        ),
        // P&L data
        Expanded(
          child: summaryAsync.when(
            loading: () => const _PLSkeleton(),
            error: (error, _) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: kAlertRed, fontSize: 14),
              ),
            ),
            data: (summary) => _PLContent(summary: summary, l10n: l10n),
          ),
        ),
      ],
    );
  }
}

// ─── P&L Content ─────────────────────────────────────────────────────────────

class _PLContent extends StatelessWidget {
  final MonthlySummary summary;
  final AppLocalizations l10n;
  const _PLContent({required this.summary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final profitColor = summary.grossProfit >= 0 ? kGreen : kAlertRed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gross profit summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurfaceGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.reportGrossProfitTitle,
                style: const TextStyle(color: kMutedGray, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${summary.grossProfit.toStringAsFixed(0)}',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: profitColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.reportGrossProfitFormula,
                style: const TextStyle(color: kMutedGray, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.reportCollectionsNote,
                style: const TextStyle(color: kMutedGray, fontSize: 12),
              ),
              if (!summary.hasData)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.reportNoRecordsMonth,
                    style: const TextStyle(color: kMutedGray, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Income
        _PLSectionHeader(
          label: l10n.reportIncomeSection,
          icon: Icons.trending_up,
          color: kGreen,
        ),
        _PLRow(
            label: l10n.reportMilkRevenue,
            value: '₹${summary.totalMilkRevenue.toStringAsFixed(0)}',
            valueColor: kGreen),
        _PLRow(
            label: l10n.reportTotalLiters,
            value: '${summary.totalLiters.toStringAsFixed(1)} L'),
        _PLRow(
            label: l10n.reportOtherIncome,
            value: '₹${summary.otherIncome.toStringAsFixed(0)}',
            valueColor: kGreen),
        const Divider(height: 28),

        // Expenses
        _PLSectionHeader(
            label: l10n.reportExpensesSection,
            icon: Icons.trending_down,
            color: kAlertRed),
        _PLRow(
            label: l10n.reportTotalExpenses,
            value: '₹${summary.totalExpenses.toStringAsFixed(0)}',
            valueColor: kAlertRed),
        const Divider(height: 28),

        // Collections
        _PLSectionHeader(
            label: l10n.reportCashCollections,
            icon: Icons.payments_outlined,
            color: kMittiBrown),
        _PLRow(
            label: l10n.reportReceivedFromCustomers,
            value: '₹${summary.totalCollected.toStringAsFixed(0)}'),
        _PLRow(
            label: l10n.reportActiveCustomers,
            value: '${summary.activeCustomerCount}'),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PLSectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _PLSectionHeader(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
}

class _PLRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _PLRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: kInkBlack, fontSize: 14)),
            Text(value,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    color: valueColor ?? kInkBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ─── Skeleton Loaders ─────────────────────────────────────────────────────────

/// List skeleton — prevents layout shift when customer list loads.
/// Also uses itemExtent for consistency with the live list.
class _StatementListSkeleton extends StatelessWidget {
  const _StatementListSkeleton();

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemExtent: kListRowHeight,
        itemBuilder: (_, __) => Container(
          height: kListRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: kSurfaceGray, width: 1),
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: kSurfaceGray, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                        color: kSurfaceGray,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 14,
                width: 64,
                decoration: BoxDecoration(
                    color: kSurfaceGray,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
      );
}

/// P&L skeleton — matches layout of _PLContent to prevent shift.
class _PLSkeleton extends StatelessWidget {
  const _PLSkeleton();

  Widget _box(double width, double height) => Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
            color: kSurfaceGray, borderRadius: BorderRadius.circular(4)),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 88,
              decoration: BoxDecoration(
                  color: kSurfaceGray, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 24),
            _box(100, 14),
            _box(double.infinity, 14),
            _box(double.infinity, 14),
            _box(double.infinity, 14),
            const SizedBox(height: 16),
            _box(80, 14),
            _box(double.infinity, 14),
          ],
        ),
      );
}
