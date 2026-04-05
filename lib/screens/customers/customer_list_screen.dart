import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_theme.dart';

/// Customer list screen.
///
/// Architecture:
///  - [activeCustomersProvider] drives the list — search is a client-side filter.
///  - Search: toggled by AppBar search icon → TextField appears below AppBar.
///    Filter is case-insensitive match on customer name.
///  - Reorder: AppBar sort icon → /customers/reorder route (drag-to-reorder).
///  - Row: 64dp (kListRowHeight). Avatar circle + name + balance badge +
///    [ادائیگی] button + [تاریخ] button. No swipe-to-delete in MVP.
///  - FAB → /customers/new (add customer).
///  - Pull-to-refresh invalidates [activeCustomersProvider].
///  - Tapping a row → /customers/:id (profile).
///  - Bottom nav index 1.
///
/// Performance (Step 24):
///  - ListView.builder with itemExtent: kListRowHeight eliminates per-item
///    layout measurement. O(1) scroll position calculation for 200-customer lists.
///  - Border drawn inside _CustomerRow (bottom side only) — no separate
///    separatorBuilder call per item.
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  bool _searchActive = false;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        break; // already here
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _query = '';
        _searchCtrl.clear();
      }
    });
  }

  List<Customer> _filtered(List<Customer> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(activeCustomersProvider);

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: _searchActive
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(color: kMutedGray),
                  border: InputBorder.none,
                ),
                style: kBodyStyle.copyWith(color: kInkBlack),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Customers'),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_searchActive ? Icons.close : Icons.search),
            tooltip: _searchActive ? 'Close' : 'Search',
            onPressed: _toggleSearch,
          ),
          // Route reorder
          if (!_searchActive)
            IconButton(
              icon: const Icon(Icons.swap_vert),
              tooltip: 'Reorder',
              onPressed: () => context.push('/customers/reorder'),
            ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const _ListSkeleton(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(activeCustomersProvider),
        ),
        data: (customers) {
          final visible = _filtered(customers);
          if (customers.isEmpty) {
            return _EmptyView(onAdd: () => context.push('/customers/new'));
          }
          if (visible.isEmpty) {
            return Center(
              child: Text(
                'No results for "$_query"',
                style: kBodyStyle.copyWith(color: kMutedGray),
              ),
            );
          }
          return RefreshIndicator(
            color: kGreen,
            onRefresh: () async => ref.invalidate(activeCustomersProvider),
            // ── Performance: itemExtent eliminates per-item layout measurement.
            // Flutter can jump to any scroll position without rendering every item.
            // _CustomerRow draws its own bottom border — no separatorBuilder needed.
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: visible.length,
              itemExtent: kListRowHeight,
              itemBuilder: (context, index) {
                return _CustomerRow(
                  customer: visible[index],
                  onTap: () =>
                      context.push('/customers/${visible[index].customerId}'),
                  onPayment: () => context.push(
                    '/payment/entry',
                    extra: visible[index].customerId,
                  ),
                  onHistory: () => context.push(
                    '/reports/statement/${visible[index].customerId}',
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/new'),
        backgroundColor: kGreen,
        foregroundColor: kWhite,
        icon: const Icon(Icons.person_add),
        label: const Text('New Customer'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

// ─── Customer row ─────────────────────────────────────────────────────────────
//
// Step 24 change: added bottom border decoration so separatorBuilder is no
// longer needed. The border visually replaces the old Divider(height:1, indent:72).

class _CustomerRow extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onPayment;
  final VoidCallback onHistory;

  const _CustomerRow({
    required this.customer,
    required this.onTap,
    required this.onPayment,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCream,
      child: InkWell(
        onTap: onTap,
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
              // ── Avatar circle ──────────────────────────────────────────
              _Avatar(name: customer.name),
              const SizedBox(width: 12),

              // ── Name + default liters ──────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: kBodyLgStyle.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${customer.defaultLiters % 1 == 0 ? customer.defaultLiters.toInt() : customer.defaultLiters.toStringAsFixed(1)} L daily',
                      style: kCaptionStyle,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Balance badge ──────────────────────────────────────────
              _BalanceBadge(balance: customer.cachedBalance),

              const SizedBox(width: 6),

              // ── Payment button ─────────────────────────────────────────
              _RowIconButton(
                icon: Icons.payments_outlined,
                color: kGreen,
                tooltip: 'Payment',
                onTap: onPayment,
              ),

              // ── History button ─────────────────────────────────────────
              _RowIconButton(
                icon: Icons.history,
                color: kMittiBrown,
                tooltip: 'History',
                onTap: onHistory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  /// Pick a stable hue from the name string — same name always same color.
  Color _avatarColor() {
    const colors = [
      Color(0xFF1B7A4A), // kGreen
      kMittiBrown,
      Color(0xFF1565C0), // blue
      Color(0xFF6A1B9A), // purple
      Color(0xFFD84315), // deep orange
      Color(0xFF00838F), // teal
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: _avatarColor(),
      child: Text(
        initials,
        style: const TextStyle(
          color: kWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Balance badge ────────────────────────────────────────────────────────────

class _BalanceBadge extends StatelessWidget {
  final double balance;
  const _BalanceBadge({required this.balance});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final String label;

    if (balance > 0.01) {
      bg = kAlertRed;
      final rounded = (balance * 100).round() / 100;
      label = '₨${rounded % 1 == 0 ? rounded.toInt() : rounded.toStringAsFixed(0)}';
    } else if (balance < -0.01) {
      bg = kAmber;
      final rounded = (balance.abs() * 100).round() / 100;
      label = '+₨${rounded % 1 == 0 ? rounded.toInt() : rounded.toStringAsFixed(0)}';
    } else {
      bg = kGreen;
      label = 'Clear';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: kCaptionStyle.copyWith(
          color: kWhite,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─── Icon button (row action) ─────────────────────────────────────────────────

class _RowIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _RowIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    // Skeleton also uses itemExtent — consistent with live list.
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemExtent: kListRowHeight,
      itemBuilder: (_, __) => Container(
        height: kListRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: kSurfaceGray, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: kSurfaceGray,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: kSurfaceGray),
                  const SizedBox(height: 6),
                  Container(height: 11, width: 70, color: kSurfaceGray),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kAlertRed, size: 48),
            const SizedBox(height: 12),
            Text('Error', style: kHeadlineStyle.copyWith(color: kAlertRed)),
            const SizedBox(height: 8),
            Text(message, style: kBodyStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, color: kMutedGray, size: 64),
            const SizedBox(height: 16),
            Text(
              'No customers yet',
              style: kHeadlineStyle.copyWith(color: kMutedGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer',
              style: kBodyLgUrduStyle.copyWith(color: kMutedGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add),
              label: const Text('New Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
