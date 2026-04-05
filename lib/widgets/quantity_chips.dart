import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Horizontal scrolling row of preset dairy quantity chips.
///
/// Covers 90%+ of real-world delivery quantities (0.5 L to 4.0 L).
/// Tapping a chip sets the quantity immediately — no numpad input required.
/// The numpad and these chips are complementary: chips for typical values,
/// numpad for unusual amounts.
///
/// Design rules:
///  - Selected chip: kGreen background, white text, no border.
///  - Unselected chip: kSurfaceGray background, kInkBlack text, kMutedGray border.
///  - Chip height: 40dp. Label font: 16sp Bold.
///  - No +0.5 key on the numpad — these chips replace that pattern.
///
/// Usage:
/// ```dart
/// double? _qty;
///
/// QuantityChips(
///   selected: _qty,
///   onSelected: (v) => setState(() => _qty = v),
/// )
/// ```
class QuantityChips extends StatelessWidget {
  /// The currently selected quantity, or null if a custom value is typed
  /// via the numpad that doesn't match any chip value.
  final double? selected;

  /// Called with the chip's value when tapped.
  final ValueChanged<double> onSelected;

  const QuantityChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<double> _quantities = [
    0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quantities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final qty = _quantities[index];
          final isSelected = selected != null &&
              (selected! - qty).abs() < 0.001; // float-safe compare
          return _Chip(
            qty: qty,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(qty);
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final double qty;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.qty,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    // Display "0.5", "1.0", "1.5" etc — always one decimal place
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? kGreen : kSurfaceGray,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: kMutedGray, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            _label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? kWhite : kInkBlack,
            ),
          ),
        ),
      ),
    );
  }
}
