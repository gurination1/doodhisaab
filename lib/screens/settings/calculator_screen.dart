import 'package:flutter/material.dart';

import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _storedValue;
  String? _pendingOperator;
  bool _resetOnNextDigit = false;

  void _handleKey(String key) {
    setState(() {
      switch (key) {
        case 'AC':
          _display = '0';
          _storedValue = null;
          _pendingOperator = null;
          _resetOnNextDigit = false;
          return;
        case '+/-':
          if (_display != '0') {
            _display =
                _display.startsWith('-') ? _display.substring(1) : '-$_display';
          }
          return;
        case '%':
          final value = double.tryParse(_display);
          if (value != null) {
            _display = _formatNumber(value / 100);
            _resetOnNextDigit = true;
          }
          return;
        case '.':
          if (_resetOnNextDigit) {
            _display = '0.';
            _resetOnNextDigit = false;
            return;
          }
          if (!_display.contains('.')) {
            _display = '$_display.';
          }
          return;
        case '=':
          _applyPending();
          _pendingOperator = null;
          _resetOnNextDigit = true;
          AnalyticsService.instance.trackFeatureUsed(
            featureName: 'calculator_used',
            screenName: 'Calculator',
            routeName: '/settings/calculator',
          );
          return;
        case '+':
        case '-':
        case 'x':
        case '÷':
          _applyPending();
          _pendingOperator = key;
          _resetOnNextDigit = true;
          return;
        default:
          if (_resetOnNextDigit || _display == '0') {
            _display = key;
            _resetOnNextDigit = false;
          } else {
            _display += key;
          }
      }
    });
  }

  void _applyPending() {
    final current = double.tryParse(_display);
    if (current == null) return;
    if (_storedValue == null || _pendingOperator == null) {
      _storedValue = current;
      _display = _formatNumber(current);
      return;
    }

    final left = _storedValue!;
    final result = switch (_pendingOperator) {
      '+' => left + current,
      '-' => left - current,
      'x' => left * current,
      '÷' => current == 0 ? null : left / current,
      _ => current,
    };

    if (result == null) {
      _display = 'Error';
      _storedValue = null;
      _pendingOperator = null;
      _resetOnNextDigit = true;
      return;
    }

    _storedValue = result;
    _display = _formatNumber(result);
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const rows = [
      ['AC', '+/-', '%', '÷'],
      ['7', '8', '9', 'x'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.calculatorTitle,
          style: const TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: kInkBlack),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kSurfaceGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _pendingOperator ?? '',
                      style: kLabelStyle.copyWith(color: kMutedGray),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kInkBlack,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Column(
                  children: rows.map((row) {
                    final isBottom = row == rows.last;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isBottom ? 0 : 10),
                        child: Row(
                          children: row.map((key) {
                            final isZero = key == '0' && row.length == 3;
                            final isOperator =
                                {'÷', 'x', '-', '+', '='}.contains(key);
                            final isUtility = {'AC', '+/-', '%'}.contains(key);
                            return Expanded(
                              flex: isZero ? 2 : 1,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: key == row.last ? 0 : 10,
                                ),
                                child: _CalcKey(
                                  label: key,
                                  fill: isOperator
                                      ? kGreen
                                      : isUtility
                                          ? kMittiBrown
                                          : kWhite,
                                  foreground: isOperator || isUtility
                                      ? kWhite
                                      : kInkBlack,
                                  onTap: () => _handleKey(key),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcKey extends StatelessWidget {
  final String label;
  final Color fill;
  final Color foreground;
  final VoidCallback onTap;

  const _CalcKey({
    required this.label,
    required this.fill,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
