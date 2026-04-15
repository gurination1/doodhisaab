import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/analytics_service.dart';
import '../../db/expense_repository.dart';
import '../../models/expense.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';

// ─────────────────────────────────────────────────────────────────────────────
const Map<String, String> _categoryLabels = {
  'Feed': 'Feed',
  'Medicine': 'Medicine',
  'Fuel': 'Fuel',
  'Electricity': 'Electricity',
  'Labor': 'Labor',
  'Other': 'Other',
};

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Step 15 — Expense Entry Screen.
///
/// Architecture:
///  - Category via visible chip row (NOT a dropdown) — low-literacy users
///    cannot discover hidden items in dropdowns.
///  - Amount via NumpadWidget — system keyboard never appears for amount.
///  - Note via system keyboard (text, not number).
///  - Write-on-save: one INSERT, no draft state.
///  - No expense edit/delete on this screen. Delete is available in Reports.
class ExpenseEntryScreen extends ConsumerStatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  ConsumerState<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends ConsumerState<ExpenseEntryScreen> {
  // ── Repo ───────────────────────────────────────────────────────────────────
  final _expenseRepo = ExpenseRepository();

  // ── Entry state ────────────────────────────────────────────────────────────
  String? _selectedCategory;
  String _numpadValue = '';
  bool _saving = false;

  // ── Note ───────────────────────────────────────────────────────────────────
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ── Derived ─────────────────────────────────────────────────────────────────

  double? get _amount => double.tryParse(_numpadValue);

  bool get _canSave =>
      !_saving && _selectedCategory != null && _amount != null && _amount! > 0;

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _doSave() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await AnalyticsService.instance.trackButtonClicked(
      buttonName: 'save_expense',
      screenName: 'Expense Entry',
      routeName: '/expenses/new',
      elementType: 'button',
      elementText: 'Save Expense',
    );
    HapticFeedback.selectionClick();

    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    await _expenseRepo.addExpense(
      category: _selectedCategory!,
      amount: _amount!,
      note: note,
    );
    await AnalyticsService.instance.trackFeatureUsed(
      featureName: 'expense_entry',
      screenName: 'Expense Entry',
      routeName: '/expenses/new',
      amount: _amount,
    );

    final now = DateTime.now();
    ref.invalidate(monthlySummaryProvider(now.year, now.month));

    if (!mounted) return;
    setState(() => _saving = false);

    final label = _categoryLabels[_selectedCategory] ?? _selectedCategory!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — ₹${_amount!.toStringAsFixed(2)} saved'),
        backgroundColor: kGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Record Expense',
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
      body: _saving
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── Category label ──────────────────────────────────────────
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Choose Category',
                      style: kLabelStyle,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Category chip row — NOT a dropdown ──────────────────────
                  _CategoryChips(
                    categories: Expense.validCategories,
                    labels: _categoryLabels,
                    selected: _selectedCategory,
                    onSelect: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 24),

                  // ── Amount label ────────────────────────────────────────────
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Amount (Rs)',
                      style: kLabelStyle,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Amount display — read-only, numpad provides input ────────
                  _AmountDisplay(numpadValue: _numpadValue),
                  const SizedBox(height: 16),

                  // ── Custom numpad — no system keyboard ──────────────────────
                  NumpadWidget(
                    value: _numpadValue,
                    onChanged: (v) => setState(() => _numpadValue = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Note — system keyboard ──────────────────────────────────
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Note (Optional)',
                      style: kLabelStyle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _NoteField(
                    controller: _noteController,
                    hint: 'Example: monthly feed',
                  ),
                  const SizedBox(height: 24),

                  // ── Save button (56dp) ──────────────────────────────────────
                  SizedBox(
                    height: kButtonHeight,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSave ? _doSave : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        disabledBackgroundColor: kSurfaceGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _canSave ? kWhite : kMutedGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Category chips ───────────────────────────────────────────────────────────

/// Visible chip row for category selection.
///
/// NOT a dropdown — dropdown items are hidden and have low discoverability
/// for low-literacy users. Chips are always visible and tappable.
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final Map<String, String> labels;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      // Chips wrap RTL — align right so they start from the right edge
      alignment: WrapAlignment.end,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        final label = labels[cat] ?? cat;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(cat);
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? kGreen : kSurfaceGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? kGreenDark : kMutedGray,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? kWhite : kInkBlack,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Amount display ───────────────────────────────────────────────────────────

/// Read-only amount display — numpad provides all input.
/// System keyboard MUST NOT appear here (no TextField used).
class _AmountDisplay extends StatelessWidget {
  final String numpadValue;
  const _AmountDisplay({required this.numpadValue});

  @override
  Widget build(BuildContext context) {
    final hasValue = numpadValue.isNotEmpty &&
        double.tryParse(numpadValue) != null &&
        double.parse(numpadValue) > 0;

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
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          numpadValue.isEmpty ? '₹0' : '₹$numpadValue',
          style: kTitleStyle.copyWith(
            color: numpadValue.isEmpty ? kMutedGray : kInkBlack,
          ),
        ),
      ),
    );
  }
}

// ─── Note field ───────────────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _NoteField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kInputHeight,
      child: TextField(
        controller: controller,
        maxLines: 1,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 16, color: kInkBlack),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kMutedGray, fontSize: 16),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: kWhite,
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
