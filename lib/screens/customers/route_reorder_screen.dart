import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/analytics_service.dart';
import '../../db/customer_repository.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouteReorderScreen
//
// Shows active customers in their current route_order.
// User drags rows to reorder. On save:
//   - Calls CustomerRepository.setRouteOrder(id, newIndex) for each customer.
//   - Invalidates [activeCustomersProvider] so list + delivery session reflect
//     the new order immediately.
//   - Pops back to customer list.
//
// Architecture notes:
//   - Local List<Customer> copy — provider is NOT used for the draggable list
//     itself to avoid flicker during drag.
//   - Save writes every position regardless of whether it changed. With ≤200
//     customers this is ≤200 UPDATE statements — negligible at target device.
//   - ReorderableListView handles drag affordance; drag handle on left side.
// ─────────────────────────────────────────────────────────────────────────────

class RouteReorderScreen extends ConsumerStatefulWidget {
  const RouteReorderScreen({super.key});

  @override
  ConsumerState<RouteReorderScreen> createState() => _RouteReorderScreenState();
}

class _RouteReorderScreenState extends ConsumerState<RouteReorderScreen> {
  List<Customer>? _customers;
  bool _saving = false;
  bool _dirty = false; // true once user has reordered at least once
  bool _reorderTracked = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final all = await CustomerRepository.instance.getActiveCustomers();
    if (mounted) {
      setState(() => _customers = List<Customer>.from(all));
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.selectionClick();
    if (!_reorderTracked) {
      _reorderTracked = true;
      AnalyticsService.instance.trackButtonClicked(
        buttonName: 'reorder_route',
        screenName: 'Route Reorder',
        routeName: '/customers/reorder',
        elementType: 'drag_handle',
        elementText: 'Reorder Route',
      );
      AnalyticsService.instance.trackFeatureUsed(
        featureName: 'route_reorder_used',
        screenName: 'Route Reorder',
        routeName: '/customers/reorder',
      );
    }
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _customers!.removeAt(oldIndex);
      _customers!.insert(newIndex, item);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_customers == null || !_dirty) {
      Navigator.of(context).pop();
      return;
    }

    await AnalyticsService.instance.trackButtonClicked(
      buttonName: 'save_route_reorder',
      screenName: 'Route Reorder',
      routeName: '/customers/reorder',
      elementType: 'button',
      elementText: 'Save',
    );
    setState(() => _saving = true);

    try {
      for (int i = 0; i < _customers!.length; i++) {
        await CustomerRepository.instance.setRouteOrder(
          _customers![i].customerId,
          i + 1, // 1-indexed to match DB convention
        );
      }
      // Refresh the list screen with new order.
      ref.invalidate(activeCustomersProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: ${e.toString()}'),
            backgroundColor: kAlertRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Reorder Route',
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: BackButton(
          color: kInkBlack,
          onPressed: () {
            if (_dirty) {
              _showDiscardDialog(context);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _dirty ? _save : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _dirty ? kGreen : kMutedGray,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kGreen,
                ),
              ),
            ),
        ],
      ),
      body: _customers == null
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _customers!.isEmpty
              ? _EmptyState()
              : Column(
                  children: [
                    // Instruction banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: kSurfaceGray,
                      child: const Text(
                        'Drag rows up or down to change the route order',
                        style: TextStyle(
                          color: kMittiBrown,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _customers!.length,
                        onReorder: _onReorder,
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final customer = _customers![index];
                          return _ReorderRow(
                            key: ValueKey(customer.customerId),
                            index: index,
                            customer: customer,
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _showDiscardDialog(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCream,
        title: const Text(
          'Discard changes?',
          style: TextStyle(color: kInkBlack, fontSize: 17),
        ),
        content: const Text(
          'The new order will not be saved.',
          style: TextStyle(color: kMutedGray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('Keep Editing', style: TextStyle(color: kMutedGray)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard',
                style:
                    TextStyle(color: kAlertRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }
}

// ─── Single reorderable row ───────────────────────────────────────────────────

class _ReorderRow extends StatelessWidget {
  final int index;
  final Customer customer;

  const _ReorderRow({
    required super.key,
    required this.index,
    required this.customer,
  });

  Color _avatarColor() {
    const colors = [
      Color(0xFF1B7A4A),
      Color(0xFF8D5524),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFD84315),
      Color(0xFF00838F),
    ];
    final idx =
        customer.name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kListRowHeight,
      color: kCream,
      child: Row(
        children: [
          // Route number badge
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  color: kMutedGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _avatarColor(),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: kWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + liters
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customer.name,
                  textDirection: TextDirection.rtl,
                  style: kBodyStyle.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${customer.defaultLiters % 1 == 0 ? customer.defaultLiters.toInt() : customer.defaultLiters.toStringAsFixed(1)} L',
                  style: kCaptionStyle,
                ),
              ],
            ),
          ),

          // Drag handle — ReorderableDragStartListener wraps the icon
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.drag_handle, color: kMutedGray, size: 26),
            ),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No customers found',
        style: TextStyle(color: kMutedGray, fontSize: 16),
      ),
    );
  }
}
