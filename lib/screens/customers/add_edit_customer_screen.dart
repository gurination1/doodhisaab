import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/customer_repository.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';
import '../../widgets/quantity_chips.dart';

/// Add / Edit customer screen.
///
/// Architecture:
///  - Receives [Customer?] via [GoRouter.extra].
///    null   → add mode (new customer, blank form)
///    non-null → edit mode (pre-populate fields, call updateCustomer)
///  - Liters input: QuantityChips for common values + NumpadWidget for custom.
///    Only one input method active at a time — chip tap overrides numpad value,
///    numpad input clears chip selection if value doesn't match a chip.
///  - Payment cycle: segmented selector (Monthly / Weekly / BiWeekly / Custom).
///    Custom shows an additional day-count field.
///  - Price override: off by default. Toggle reveals a numpad amount field.
///  - Validation: name required. All other fields optional.
///  - Save: addCustomer() or updateCustomer() → ref.invalidate(activeCustomersProvider) → pop.
///  - No unsaved-changes guard in MVP — keep it simple for illiterate users.
class AddEditCustomerScreen extends ConsumerStatefulWidget {
  /// Non-null when editing an existing customer. Null when adding a new one.
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  bool get isEdit => customer != null;

  @override
  ConsumerState<AddEditCustomerScreen> createState() =>
      _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState
    extends ConsumerState<AddEditCustomerScreen> {
  final _repo = CustomerRepository();

  // ── Form controllers ───────────────────────────────────────────────────────
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();

  // ── Liters input ───────────────────────────────────────────────────────────
  double? _selectedLiters;   // chip selection
  String  _litersInput = ''; // numpad raw string

  // ── Payment cycle ──────────────────────────────────────────────────────────
  String _paymentCycle     = 'Monthly';
  final _cycleDaysController = TextEditingController();

  // ── Price override ─────────────────────────────────────────────────────────
  bool   _priceOverrideEnabled = false;
  String _priceInput           = '';
  final _priceReasonController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  bool    _saving     = false;
  String? _nameError;

  // ── Focus ──────────────────────────────────────────────────────────────────
  // Which numpad is active: 'liters' | 'price'
  String _activeNumpad = 'liters';

  @override
  void initState() {
    super.initState();
    _prefillIfEdit();
  }

  void _prefillIfEdit() {
    final c = widget.customer;
    if (c == null) {
      // Default: 2 liters / Monthly
      _selectedLiters = 2.0;
      _litersInput    = '2';
      return;
    }
    _nameController.text    = c.name;
    _phoneController.text   = c.phone    ?? '';
    _addressController.text = c.address  ?? '';

    _selectedLiters = c.defaultLiters;
    _litersInput    = doubleToNumpadValue(c.defaultLiters);

    _paymentCycle = c.paymentCycle;
    if (c.paymentCycleDays != null) {
      _cycleDaysController.text = '${c.paymentCycleDays}';
    }

    if (c.priceOverride != null) {
      _priceOverrideEnabled = true;
      _priceInput           = doubleToNumpadValue(c.priceOverride!);
      _priceReasonController.text = c.priceOverrideReason ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cycleDaysController.dispose();
    _priceReasonController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'نام ضروری ہے');
      return false;
    }
    setState(() => _nameError = null);
    return true;
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_validate()) return;

    final liters = numpadValueToDouble(_litersInput) ?? _selectedLiters ?? 2.0;
    final priceOverride = _priceOverrideEnabled
        ? numpadValueToDouble(_priceInput)
        : null;
    int? cycleDays;
    if (_paymentCycle == 'Custom') {
      cycleDays = int.tryParse(_cycleDaysController.text.trim());
    }

    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        final updated = widget.customer!.copyWith(
          name:                _nameController.text.trim(),
          phone:               _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address:             _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          defaultLiters:       liters,
          paymentCycle:        _paymentCycle,
          paymentCycleDays:    cycleDays,
          priceOverride:       priceOverride,
          priceOverrideReason: _priceOverrideEnabled &&
                  _priceReasonController.text.trim().isNotEmpty
              ? _priceReasonController.text.trim()
              : null,
        );
        await _repo.updateCustomer(updated);
      } else {
        await _repo.addCustomer(
          name:                _nameController.text.trim(),
          phone:               _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address:             _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          defaultLiters:       liters,
          paymentCycle:        _paymentCycle,
          paymentCycleDays:    cycleDays,
          priceOverride:       priceOverride,
          priceOverrideReason: _priceOverrideEnabled &&
                  _priceReasonController.text.trim().isNotEmpty
              ? _priceReasonController.text.trim()
              : null,
        );
      }
      ref.invalidate(activeCustomersProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'ترمیم کریں' : 'نیا گاہک'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      // ── Name (required) ──────────────────────────────────
                      _FieldLabel(text: 'نام *'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: kBodyLgStyle,
                        decoration: InputDecoration(
                          hintText: 'مثال: احمد علی',
                          errorText: _nameError,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Phone (optional) ────────────────────────────────
                      _FieldLabel(text: 'فون نمبر (اختیاری)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: kBodyLgStyle,
                        decoration: const InputDecoration(
                          hintText: '03XX-XXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Address (optional) ──────────────────────────────
                      _FieldLabel(text: 'پتہ (اختیاری)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _addressController,
                        style: kBodyLgStyle,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'گلی / محلہ',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Default liters ───────────────────────────────────
                      _FieldLabel(text: 'روزانہ دودھ (لیٹر)'),
                      const SizedBox(height: 8),

                      // Display value
                      _NumpadDisplay(
                        value: _litersInput,
                        suffix: 'لیٹر',
                        isActive: _activeNumpad == 'liters',
                        onTap: () => setState(() => _activeNumpad = 'liters'),
                      ),

                      const SizedBox(height: 10),

                      // Quick-pick chips
                      QuantityChips(
                        selected: _selectedLiters,
                        onSelected: (v) {
                          setState(() {
                            _selectedLiters = v;
                            _litersInput    = doubleToNumpadValue(v);
                            _activeNumpad   = 'liters';
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // Numpad (only shown when liters is active)
                      if (_activeNumpad == 'liters')
                        NumpadWidget(
                          value: _litersInput,
                          onChanged: (v) {
                            setState(() {
                              _litersInput = v;
                              final parsed = numpadValueToDouble(v);
                              // Sync chip selection if value matches a chip
                              _selectedLiters = parsed;
                            });
                          },
                        ),

                      const SizedBox(height: 20),

                      // ── Payment cycle ────────────────────────────────────
                      _FieldLabel(text: 'ادائیگی سائیکل'),
                      const SizedBox(height: 8),
                      _CycleSelector(
                        selected: _paymentCycle,
                        onChanged: (v) => setState(() => _paymentCycle = v),
                      ),

                      // Custom days input
                      if (_paymentCycle == 'Custom') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _cycleDaysController,
                          keyboardType: TextInputType.number,
                          style: kBodyLgStyle,
                          decoration: const InputDecoration(
                            hintText: 'دن درج کریں',
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixText: 'دن',
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Price override ───────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FieldLabel(text: 'خصوصی قیمت'),
                          Switch(
                            value: _priceOverrideEnabled,
                            activeColor: kGreen,
                            onChanged: (v) =>
                                setState(() => _priceOverrideEnabled = v),
                          ),
                        ],
                      ),

                      if (_priceOverrideEnabled) ...[
                        const SizedBox(height: 8),

                        _NumpadDisplay(
                          value: _priceInput,
                          prefix: '₨',
                          suffix: 'فی لیٹر',
                          isActive: _activeNumpad == 'price',
                          onTap: () =>
                              setState(() => _activeNumpad = 'price'),
                        ),

                        const SizedBox(height: 10),

                        if (_activeNumpad == 'price')
                          NumpadWidget(
                            value: _priceInput,
                            onChanged: (v) =>
                                setState(() => _priceInput = v),
                          ),

                        const SizedBox(height: 10),
                        TextField(
                          controller: _priceReasonController,
                          style: kBodyStyle,
                          decoration: const InputDecoration(
                            hintText: 'وجہ (اختیاری)',
                            prefixIcon: Icon(Icons.notes),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── Save button (pinned) ─────────────────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(kButtonHeight),
                      ),
                      child: Text(
                        widget.isEdit ? 'تبدیلیاں محفوظ کریں' : 'گاہک شامل کریں',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'NotoNastaliqUrdu',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: kLabelStyle.copyWith(fontFamily: 'NotoNastaliqUrdu', height: 1.6),
    );
  }
}

/// Read-only tap target that shows the current numpad value.
/// Tapping makes it the active numpad (shows numpad below).
class _NumpadDisplay extends StatelessWidget {
  final String value;
  final String? prefix;
  final String? suffix;
  final bool isActive;
  final VoidCallback onTap;

  const _NumpadDisplay({
    required this.value,
    required this.isActive,
    required this.onTap,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? '0' : value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kInputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? kGreen : kMutedGray,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (prefix != null) ...[
              Text(prefix!,
                  style: kBodyLgStyle.copyWith(color: kMutedGray)),
              const SizedBox(width: 6),
            ],
            Text(
              displayValue,
              style: kHeadlineStyle.copyWith(
                color: isActive ? kGreen : kInkBlack,
                fontSize: 26,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 6),
              Text(suffix!,
                  style: kBodyLgStyle.copyWith(
                    color: kMutedGray,
                    fontFamily: 'NotoNastaliqUrdu',
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Payment cycle segmented selector.
class _CycleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CycleSelector({
    required this.selected,
    required this.onChanged,
  });

  static const _options = [
    ('Monthly',   'ماہانہ'),
    ('Weekly',    'ہفتہ وار'),
    ('BiWeekly',  'دو ہفتہ'),
    ('Custom',    'اپنی مرضی'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final (value, label) = opt;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? kGreen : kSurfaceGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? kGreen : kMutedGray,
              ),
            ),
            child: Text(
              label,
              style: kBodyStyle.copyWith(
                color: isSelected ? kWhite : kInkBlack,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'NotoNastaliqUrdu',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
