import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Custom numpad for all liter/amount input in the app.
///
/// Architecture rules enforced here:
///  - InkWell + Material for every key — gives ripple feedback.
///    GestureDetector gives no visual feedback → users double-tap → double-entry bugs.
///  - HapticFeedback.selectionClick() — NOT mediumImpact().
///    mediumImpact requires API 26; our target is API 24. It silently does nothing.
///  - System keyboard NEVER appears. Use [readOnly: true] on any TextField
///    that displays this numpad's output.
///
/// Decimal snapping:
///  - Only .0 and .5 are valid decimal parts (dairy milk = whole or half liters).
///  - Tapping a non-{0,5} digit after the decimal point snaps to the nearest valid
///    value and shows a brief SnackBar: "نزدیک ترین: X.Y"
///  - Digits 1,2 → snap to .0  |  digits 3–7 → snap to .5  |  digits 8,9 → snap to .5
///
/// Usage:
/// ```dart
/// String _value = '';
///
/// NumpadWidget(
///   value: _value,
///   onChanged: (v) => setState(() => _value = v),
/// )
/// ```
class NumpadWidget extends StatelessWidget {
  /// Current string value displayed in the parent's input field.
  /// Empty string means no input yet.
  final String value;

  /// Called with the new value string every time a key is tapped.
  /// Parent is responsible for holding and updating state.
  final ValueChanged<String> onChanged;

  const NumpadWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // KEY LOGIC
  // ─────────────────────────────────────────────────────────────────────────

  String _handleKey(BuildContext context, String key) {
    switch (key) {
      case '⌫':
        if (value.isEmpty) return value;
        final trimmed = value.substring(0, value.length - 1);
        // If we just removed the decimal point's trailing digit, keep the dot
        // so the user sees "2." and can re-enter — handled naturally.
        return trimmed;

      case '.':
        if (value.isEmpty) return '0.'; // leading zero before decimal
        if (value.contains('.')) return value; // already has decimal — ignore
        return '$value.';

      default: // digit 0–9
        return _handleDigit(context, key);
    }
  }

  String _handleDigit(BuildContext context, String digit) {
    // Digit after the decimal point
    if (value.contains('.')) {
      final parts = value.split('.');
      final intPart = parts[0];
      final decPart = parts[1];

      // One decimal digit already filled — ignore further digits
      if (decPart.isNotEmpty) return value;

      final d = int.parse(digit);

      // Valid digits — accept as-is
      if (d == 0 || d == 5) return '$value$digit';

      // Invalid digit — snap to nearest valid decimal part
      // Snap rule: 1,2 → .0  |  3,4,5,6,7,8,9 → .5
      // (d==5 handled above, so here d ∈ {1,2,3,4,6,7,8,9})
      final snappedDec = d <= 2 ? '0' : '5';
      final snapped = '$intPart.$snappedDec';

      // Notify user via SnackBar — brief, non-blocking
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'نزدیک ترین: $snapped',
              textDirection: TextDirection.rtl,
            ),
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );

      return snapped;
    }

    // No decimal yet — handle integer part
    if (value == '0' || value.isEmpty) {
      // Replace lone zero or empty with the new digit (no leading zeros)
      return digit == '0' ? '0' : digit;
    }

    // Cap at 4 characters total (max realistic value: 99.5 → "99.5" = 4 chars)
    // This prevents absurdly large liter values from being entered
    if (value.length >= 4) return value;

    return '$value$digit';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 4),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 4),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 4),
        _buildRow(context, ['.', '0', '⌫']),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys
          .expand((k) => [
                Expanded(child: _buildKey(context, k)),
                if (k != keys.last) const SizedBox(width: 4),
              ])
          .toList(),
    );
  }

  /// Each key: Material (for ripple clip) wrapping InkWell.
  /// NOT GestureDetector — no visual feedback → double-tap → double-entry.
  Widget _buildKey(BuildContext context, String label) {
    final isBackspace = label == '⌫';

    return Material(
      color: isBackspace ? kSurfaceGray : kSurfaceGray,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () {
          // selectionClick() — the only safe haptic on API 24.
          // mediumImpact() requires API 26 and silently does nothing on target devices.
          HapticFeedback.selectionClick();
          final next = _handleKey(context, label);
          if (next != value) onChanged(next);
        },
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 64,
          child: Center(
            child: isBackspace
                ? const Icon(Icons.backspace_outlined, size: 26, color: kInkBlack)
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: kInkBlack,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Converts a numpad string value to a double.
///
/// Returns null if the value is empty or incomplete (e.g. "2." with no decimal digit).
double? numpadValueToDouble(String value) {
  if (value.isEmpty) return null;
  if (value.endsWith('.')) return null; // incomplete
  return double.tryParse(value);
}

/// Converts a double back to a numpad display string.
///
/// Uses .0 and .5 representations. E.g. 2.0 → "2.0", 2.5 → "2.5", 3.0 → "3.0".
String doubleToNumpadValue(double v) {
  // Snap to nearest .0 or .5
  final floored = v.floor();
  final frac = v - floored;
  final snappedFrac = frac < 0.25
      ? 0.0
      : frac < 0.75
          ? 0.5
          : 0.0; // round up would be next integer
  final extra = frac >= 0.75 ? 1 : 0;
  final result = (floored + extra) + snappedFrac;

  if (result % 1.0 == 0) {
    return result.toInt().toString();
  }
  return result.toStringAsFixed(1);
}
