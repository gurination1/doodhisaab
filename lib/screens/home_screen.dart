import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/customer_provider.dart';
import '../providers/delivery_provider.dart';
import '../theme/app_theme.dart';

/// Home / dashboard screen.
///
/// Architecture:
///  - Two async providers: [activeCustomersProvider] + [todayDeliveriesProvider].
///    Each resolves independently — stats update without blocking each other.
///  - Bottom nav index 0. Go-router replaces (go) not pushes (push) on tab switch
///    so history doesn't accumulate. Deep-action buttons use push (overlay modal).
///  - Date card uses DateTime.now() — display-only, no provider needed.
///  - Semantic color rules from app_theme: Green = confirmed, Amber = incomplete,
///    Red = error. Never decorative.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // already here
      case 1:
        context.go('/customers');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync  = ref.watch(activeCustomersProvider);
    final deliveriesAsync = ref.watch(todayDeliveriesProvider);
    final now             = DateTime.now();

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text('DoodHisaab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kGreen,
        onRefresh: () async {
          ref.invalidate(activeCustomersProvider);
          ref.invalidate(todayDeliveriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            // ── Date card ──────────────────────────────────────────────────
            _DateCard(date: now),

            const SizedBox(height: 10),

            // ── Stats row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Served today / total
                  Expanded(
                    child: _StatCard(
                      label: 'Served',
                      value: deliveriesAsync.when(
                        loading: () => null,
                        error: (_, __) => '—',
                        data: (dels) => '${dels.where((d) => d.status == 'confirmed').length}',
                      ),
                      suffix: customersAsync.maybeWhen(
                        data: (cs) => '/ ${cs.length}',
                        orElse: () => null,
                      ),
                      icon: Icons.check_circle_outline,
                      color: kGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Total liters today
                  Expanded(
                    child: _StatCard(
                      label: 'Liters',
                      value: deliveriesAsync.when(
                        loading: () => null,
                        error: (_, __) => '—',
                        data: (dels) {
                          final l = dels
                              .where((d) => d.status == 'confirmed')
                              .fold(0.0, (s, d) => s + d.liters);
                          return l % 1 == 0 ? '${l.toInt()}' : l.toStringAsFixed(1);
                        },
                      ),
                      icon: Icons.water_drop_outlined,
                      color: kAmber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Active customers
                  Expanded(
                    child: _StatCard(
                      label: 'Customers',
                      value: customersAsync.when(
                        loading: () => null,
                        error: (_, __) => '—',
                        data: (cs) => '${cs.length}',
                      ),
                      icon: Icons.people_outline,
                      color: kMittiBrown,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Primary action: Start delivery ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/delivery/entry'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kConfirmButtonHeight),
                  backgroundColor: kGreen,
                  foregroundColor: kWhite,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoNastaliqUrdu',
                  ),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 28),
                label: const Text('Start Delivery'),
              ),
            ),

            const SizedBox(height: 12),

            // ── Secondary action: Record payment ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/payment/entry'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kButtonHeight),
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen, width: 1.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'NotoNastaliqUrdu',
                  ),
                ),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Record Payment'),
              ),
            ),

            const SizedBox(height: 12),

            // ── Quick actions row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _QuickTile(
                    label: 'Customers',
                    icon: Icons.people_outline,
                    onTap: () => context.go('/customers'),
                  ),
                  const SizedBox(width: 10),
                  _QuickTile(
                    label: 'Reports',
                    icon: Icons.bar_chart_outlined,
                    onTap: () => context.go('/reports'),
                  ),
                  const SizedBox(width: 10),
                  _QuickTile(
                    label: 'Expenses',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => context.push('/expenses/new'),
                  ),
                  const SizedBox(width: 10),
                  _QuickTile(
                    label: 'Income',
                    icon: Icons.add_circle_outline,
                    onTap: () => context.push('/income/new'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Today's delivery summary banner ────────────────────────────
            deliveriesAsync.when(
              loading: () => const _SkeletonBanner(),
              error: (_, __) => const SizedBox.shrink(),
              data: (dels) {
                final confirmed = dels.where((d) => d.status == 'confirmed').toList();
                if (confirmed.isEmpty) return const _EmptyBanner();
                final liters = confirmed.fold(0.0, (s, d) => s + d.liters);
                final litersText = liters % 1 == 0
                    ? '${liters.toInt()}'
                    : liters.toStringAsFixed(1);
                return _SuccessBanner(
                  count: confirmed.length,
                  litersText: litersText,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) => _onNavTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _DateCard extends StatelessWidget {
  final DateTime date;
  const _DateCard({required this.date});

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final label = '${date.day} ${_months[date.month]} ${date.year}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: kGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: kWhite, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today',
                  style: kCaptionStyle.copyWith(color: kWhite.withOpacity(0.8))),
              const SizedBox(height: 2),
              Text(
                label,
                style: kTitleStyle.copyWith(
                  color: kWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String? value;   // null = loading
  final String? suffix;  // optional denominator text
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSurfaceGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          if (value == null)
            Container(
              width: 36,
              height: 18,
              decoration: BoxDecoration(
                color: kSurfaceGray,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value!, style: kTitleStyle.copyWith(color: color, fontSize: 20)),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(suffix!, style: kCaptionStyle),
                ],
              ],
            ),
          const SizedBox(height: 4),
          Text(label,
              style: kCaptionStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: kGreen, size: 24),
                const SizedBox(height: 5),
                Text(label,
                    style: kLabelStyle.copyWith(color: kGreen),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final int count;
  final String litersText;
  const _SuccessBanner({required this.count, required this.litersText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'آج $count گاہکوں کو $litersText لیٹر دودھ دیا گیا',
              style: kBodyLgUrduStyle.copyWith(color: kGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBanner extends StatelessWidget {
  const _EmptyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAmber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: kAmber, size: 26),
          const SizedBox(width: 12),
          Text(
            'آج ابھی کوئی ڈیری درج نہیں ہوئی',
            style: kBodyLgUrduStyle.copyWith(color: kAmber),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBanner extends StatelessWidget {
  const _SkeletonBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 60,
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
