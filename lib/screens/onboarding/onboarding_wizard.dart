import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/customer_repository.dart';
import '../../db/price_repository.dart';
import '../../db/settings_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';
import '../../widgets/quantity_chips.dart';

/// Onboarding wizard — shown once on first launch.
///
/// Gate: only visible when [SettingsRepository.isFirstLaunchDone] returns false.
/// The gate is enforced in [LockScreen] which redirects here before PIN entry.
///
/// Flow:
///   Screen 1 — Set milk price (custom numpad, skip allowed)
///   Screen 2 — Add first customer: name + qty only (2 fields MAX, skip allowed)
///   Screen 3 — Summary → calls markFirstLaunchDone() → data warning → /home
///
/// Architecture notes:
///  - PageView with NeverScrollableScrollPhysics — navigation via buttons only.
///  - Price and customer are written to SQLite when the user taps "Next" (not at
///    end). This prevents data loss if the user force-quits mid-wizard.
///  - System keyboard NEVER appears for any number field — NumpadWidget only.
///  - Quantity chips replace numpad for liter selection on Screen 2.
class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final _pageController = PageController();
  int _currentPage = 0;

  // ── Screen 1 ───────────────────────────────────────────────────────────────
  String _priceValue = '';

  // ── Screen 2 ───────────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  double? _selectedQty;

  // ── Shared ─────────────────────────────────────────────────────────────────
  bool _isSaving = false;

  // Track whether each step's data has already been written to SQLite,
  // so back-and-forward navigation doesn't insert duplicates.
  bool _priceSaved = false;
  bool _customerSaved = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _onPriceNext() async {
    if (!_priceSaved) {
      final price = double.tryParse(_priceValue);
      if (price != null && price > 0) {
        await PriceRepository().setPrice(price, note: 'onboarding');
      }
      _priceSaved = true;
    }
    _animateTo(1);
  }

  Future<void> _onCustomerNext() async {
    if (!_customerSaved) {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await CustomerRepository().addCustomer(
          name: name,
          defaultLiters: _selectedQty ?? 2.0,
        );
      }
      _customerSaved = true;
    }
    _animateTo(2);
  }

  Future<void> _finish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await SettingsRepository.instance.markFirstLaunchDone();
    setState(() => _isSaving = false);
    if (!mounted) return;
    _showDataWarning();
  }

  void _showDataWarning() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'اپنا ڈیٹا محفوظ رکھیں',
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'آپ کا تمام ڈیٹا اس فون میں محفوظ ہے۔\n\n'
          'اگر فون گم ہو یا خراب ہو تو ڈیٹا ضائع ہو سکتا ہے۔\n\n'
          'ہفتہ وار بیک اپ خودبخود ڈاؤن لوڈز فولڈر میں محفوظ ہوتا ہے۔\n'
          'آپ سیٹنگز میں جا کر ابھی بیک اپ لے سکتے ہیں۔',
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kGreen),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) context.go('/home');
            },
            child: const Text(
              'سمجھ گیا',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(currentPage: _currentPage),
            Expanded(
              child: PageView(
                controller: _pageController,
                // Swipe disabled — buttons only. Low-literacy users accidentally
                // swipe and lose their place. All navigation is explicit.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PricePage(
                    value: _priceValue,
                    onChanged: (v) => setState(() => _priceValue = v),
                    onNext: _onPriceNext,
                    onSkip: () {
                      _priceSaved = true;
                      _animateTo(1);
                    },
                  ),
                  _CustomerPage(
                    nameController: _nameController,
                    selectedQty: _selectedQty,
                    onQtySelected: (q) => setState(() => _selectedQty = q),
                    onBack: () => _animateTo(0),
                    onNext: _onCustomerNext,
                    onSkip: () {
                      _customerSaved = true;
                      _animateTo(2);
                    },
                  ),
                  _ConfirmPage(
                    price: _priceValue,
                    customerName: _nameController.text.trim(),
                    qty: _selectedQty,
                    isSaving: _isSaving,
                    onBack: () => _animateTo(1),
                    onStart: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int currentPage;
  const _ProgressBar({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: i <= currentPage ? kGreen : kSurfaceGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1 — Set Milk Price
// ─────────────────────────────────────────────────────────────────────────────

class _PricePage extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _PricePage({
    required this.value,
    required this.onChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'فی لیٹر دودھ کی قیمت',
                textDirection: TextDirection.rtl,
                style: kHeadlineStyle,
              ),
              const SizedBox(height: 16),
              // Price display — readOnly display only; NumpadWidget provides input.
              // System keyboard must NEVER appear for number input.
              Container(
                height: kInputHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: value.isNotEmpty ? kGreen : kMutedGray,
                    width: value.isNotEmpty ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.isEmpty ? '₹ 0' : '₹ $value',
                      style: kTitleStyle.copyWith(
                        color: value.isEmpty ? kMutedGray : kInkBlack,
                      ),
                    ),
                    Text(
                      'فی لیٹر',
                      textDirection: TextDirection.rtl,
                      style: kBodyStyle.copyWith(color: kMutedGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        NumpadWidget(value: value, onChanged: onChanged),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: ElevatedButton(
            onPressed: onNext,
            child: const Text(
              'آگے',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: kMutedGray),
            onPressed: onSkip,
            child: const Text(
              'چھوڑیں',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 — First Customer  (2 fields ONLY — name + quantity)
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerPage extends StatelessWidget {
  final TextEditingController nameController;
  final double? selectedQty;
  final ValueChanged<double> onQtySelected;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CustomerPage({
    required this.nameController,
    required this.selectedQty,
    required this.onQtySelected,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          const Text(
            'پہلا گاہک شامل کریں',
            textDirection: TextDirection.rtl,
            style: kHeadlineStyle,
          ),
          const SizedBox(height: 20),

          // ── Field 1: Name ───────────────────────────────────────────────────
          // Text field — system keyboard IS allowed for name input (not a number).
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'گاہک کا نام',
              textDirection: TextDirection.rtl,
              style: kLabelStyle,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            style: kBodyLgUrduStyle,
            decoration: const InputDecoration(
              hintText: 'مثلاً: احمد خان',
              hintTextDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 24),

          // ── Field 2: Default Quantity — quantity chips ONLY ─────────────────
          // NO numpad here. Chips cover 100% of typical dairy quantities.
          // DO NOT add phone, payment cycle, address, or any other field.
          // 4+ fields → ~40% abandonment; 2 fields is the maximum.
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'عام یومیہ مقدار',
              textDirection: TextDirection.rtl,
              style: kLabelStyle,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: QuantityChips(
              selected: selectedQty,
              onSelected: onQtySelected,
            ),
          ),
          const SizedBox(height: 20),

          // ── Reassurance hint ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSurfaceGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'آپ بعد میں فون اور ادائیگی کا طریقہ شامل کر سکتے ہیں',
              textDirection: TextDirection.rtl,
              style: kBodyStyle,
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text(
                    'پیچھے',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text(
                    'آگے',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: kMutedGray),
              onPressed: onSkip,
              child: const Text(
                'چھوڑیں',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3 — Confirm & Start
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmPage extends StatelessWidget {
  final String price;
  final String customerName;
  final double? qty;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onStart;

  const _ConfirmPage({
    required this.price,
    required this.customerName,
    required this.qty,
    required this.isSaving,
    required this.onBack,
    required this.onStart,
  });

  bool get _hasPrice {
    final v = double.tryParse(price);
    return v != null && v > 0;
  }

  bool get _hasCustomer => customerName.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'شروع کرنے کے لیے تیار!',
            textDirection: TextDirection.rtl,
            style: kHeadlineStyle,
          ),
          const SizedBox(height: 24),

          // ── Summary card ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kSurfaceGray),
            ),
            child: _hasPrice || _hasCustomer
                ? Column(
                    children: [
                      if (_hasPrice)
                        _SummaryRow(
                          icon: Icons.currency_rupee,
                          label: 'فی لیٹر قیمت',
                          value: '₹ $price',
                        ),
                      if (_hasPrice && _hasCustomer) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                      ],
                      if (_hasCustomer) ...[
                        _SummaryRow(
                          icon: Icons.person_outline,
                          label: 'پہلا گاہک',
                          value: customerName,
                        ),
                        if (qty != null) ...[
                          const SizedBox(height: 12),
                          _SummaryRow(
                            icon: Icons.water_drop,
                            label: 'یومیہ مقدار',
                            value: '${qty!.toStringAsFixed(1)} لیٹر',
                          ),
                        ],
                      ],
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'آپ بعد میں قیمت اور گاہک شامل کر سکتے ہیں',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: kBodyStyle,
                    ),
                  ),
          ),

          const Spacer(),

          // ── Primary CTA — kConfirmButtonHeight (72dp) ──────────────────────
          SizedBox(
            height: kConfirmButtonHeight,
            child: ElevatedButton(
              onPressed: isSaving ? null : onStart,
              child: isSaving
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        color: kWhite,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'شروع کریں',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBack,
            child: const Text(
              'پیچھے',
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary row
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: kGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            textDirection: TextDirection.rtl,
            style: kBodyStyle.copyWith(color: kMutedGray),
          ),
        ),
        Text(
          value,
          style: kBodyLgStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
