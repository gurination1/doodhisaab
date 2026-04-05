import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/settings_repository.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SettingsScreen
//
// Sections:
//   زبان      — اردو / انگریزی / پنجابی                    (Step 21)
//   ڈسپلے    — آؤٹ ڈور موڈ                               (Step 21 — wired)
//   قیمت      — دودھ کی قیمت → /settings/price           (Step 14)
//   سیکیورٹی  — PIN لگائیں / تبدیل کریں + PIN ہٹائیں   (Step 17)
//   ڈیٹا     — بیک اپ + CSV برآمد + ڈیٹا کی حفاظت      (Steps 18/20/23)
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // null = not yet loaded, empty = loaded but no PIN set.
  String? _pinHash;
  bool _pinLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPinStatus();
  }

  Future<void> _loadPinStatus() async {
    final hash = await SettingsRepository.instance.getPinHash();
    if (mounted) {
      setState(() {
        _pinHash = hash;
        _pinLoaded = true;
      });
    }
  }

  // ── LANGUAGE ───────────────────────────────────────────────────────────────

  Future<void> _changeLanguage(String code) async {
    await SettingsRepository.instance.setLanguage(code);
    ref.invalidate(languageProvider);
    HapticFeedback.selectionClick();
  }

  Future<void> _changeThemeMode(String mode) async {
    await SettingsRepository.instance.setThemeMode(mode);
    ref.invalidate(themeModeProvider);
    HapticFeedback.selectionClick();
  }

  // ── PIN MANAGEMENT ─────────────────────────────────────────────────────────

  Future<void> _showSetPinSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SetPinSheet(
        isChanging: _pinHash != null,
        onPinSet: (newPin) async {
          await SettingsRepository.instance.setPinHash(newPin);
          if (mounted) {
            await _loadPinStatus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _pinHash != null ? 'PIN تبدیل ہو گئی' : 'PIN لگ گئی',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: kGreen,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmRemovePin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCream,
        title: const Text(
          'PIN ہٹائیں؟',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: kInkBlack, fontSize: 17),
        ),
        content: const Text(
          'PIN ہٹانے کے بعد ایپ بغیر PIN کے کھلے گی۔',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: kMutedGray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('منسوخ', style: TextStyle(color: kMutedGray)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ہٹائیں',
                style: TextStyle(color: kAlertRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SettingsRepository.instance.clearPin();
      await _loadPinStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PIN ہٹا دی گئی',
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── DATA WARNING INFO ──────────────────────────────────────────────────────
  //
  // Same content as the onboarding first-launch dialog, but accessible
  // at any time via Settings → ڈیٹا → ڈیٹا کی حفاظت.
  // barrierDismissible: true here (user chose to open it, can dismiss freely).

  void _showDataWarningInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'سمجھ گیا',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentLang  = ref.watch(languageProvider).valueOrNull ?? 'en';
    final currentThemeMode = ref.watch(themeModeProvider).valueOrNull ?? 'system';

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kInkBlack),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ListView(
        children: [
          // ── Language ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Language'),
          _LanguageSelector(
            currentCode: currentLang,
            onSelect: _changeLanguage,
          ),

          // ── Display ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Theme'),
          _ThemeSelector(
            currentMode: currentThemeMode,
            onSelect: _changeThemeMode,
          ),

          // ── Pricing ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Pricing'),
          _SettingsTile(
            icon: Icons.monetization_on_outlined,
            label: 'Milk Price',
            subtitle: 'View current price and history',
            onTap: () => context.push('/settings/price'),
          ),

          // ── Security ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Security'),
          if (!_pinLoaded)
            // Skeleton row while loading PIN status.
            const SizedBox(height: kListRowHeight),
          if (_pinLoaded) ...[
            _SettingsTile(
              icon: Icons.lock_outline,
              label: _pinHash == null ? 'Set PIN' : 'Change PIN',
              subtitle: _pinHash == null
                  ? 'Protect the app with a PIN'
                  : 'Set a new 4-digit PIN',
              onTap: () => _showSetPinSheet(context),
            ),
            if (_pinHash != null)
              _SettingsTile(
                icon: Icons.lock_open_outlined,
                label: 'Remove PIN',
                subtitle: 'App will open without a PIN',
                danger: true,
                onTap: () => _confirmRemovePin(context),
              ),
          ],

          // ── Data ─────────────────────────────────────────────────────────
          _SectionHeader(label: 'Data'),
          _SettingsTile(
            icon: Icons.backup_outlined,
            label: 'Backup',
            subtitle: 'Save into Downloads/DoodHisaab/',
            onTap: () => context.push('/settings/backup'),
          ),
          _SettingsTile(
            icon: Icons.file_download_outlined,
            label: 'Export CSV',
            subtitle: 'Create a spreadsheet-friendly file',
            onTap: () => context.push('/settings/export'),
          ),
          // Step 23 — data safety info tile.
          // Same content as first-launch dialog, accessible at any time.
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'Data Safety',
            subtitle: 'What happens if the phone is lost or damaged?',
            onTap: () => _showDataWarningInfo(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SetPinSheet — modal bottom sheet for setting / changing PIN.
//
// Two-step flow:
//   Step 1 — "نیا PIN"    → enter 4 digits → auto-advance
//   Step 2 — "تصدیق کریں" → enter same 4 → match → save → close sheet
//   Mismatch → shake dots + "PIN مختلف ہے" text + restart step 2
// ─────────────────────────────────────────────────────────────────────────────

class _SetPinSheet extends StatefulWidget {
  final bool isChanging;
  final Future<void> Function(String pin) onPinSet;

  const _SetPinSheet({required this.isChanging, required this.onPinSet});

  @override
  State<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<_SetPinSheet>
    with SingleTickerProviderStateMixin {
  int _step = 1; // 1 = enter new PIN, 2 = confirm PIN
  String _first = '';
  String _input = '';
  String? _errorMsg;
  bool _saving = false;

  late final AnimationController _shakeCtrl;
  late final Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnim = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
          weight: 2),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.05, 0), end: Offset.zero),
          weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_input.length >= 4) return;
    final next = _input + digit;
    setState(() {
      _input = next;
      _errorMsg = null;
    });
    if (next.length == 4) _onComplete(next);
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _errorMsg = null;
    });
  }

  Future<void> _onComplete(String pin) async {
    if (_step == 1) {
      // Step 1 done — move to confirm.
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        setState(() {
          _first = pin;
          _input = '';
          _step = 2;
        });
      }
    } else {
      // Step 2 — verify match.
      if (pin == _first) {
        setState(() => _saving = true);
        await widget.onPinSet(pin);
        if (mounted) Navigator.of(context).pop();
      } else {
        HapticFeedback.selectionClick();
        _shakeCtrl.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              _input = '';
              _errorMsg = 'PIN مختلف ہے — دوبارہ کوشش کریں';
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _step == 1
        ? (widget.isChanging ? 'نیا PIN درج کریں' : 'PIN لگائیں')
        : 'PIN تصدیق کریں';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kSurfaceGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              textDirection: TextDirection.rtl,
              style: kBodyStyle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: kInkBlack,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dot indicators + error message
          SlideTransition(
            position: _shakeAnim,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _input.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? kGreen : Colors.transparent,
                        border: Border.all(
                          color: _errorMsg != null
                              ? kAlertRed
                              : (filled ? kGreen : kMutedGray),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMsg!,
                    textDirection: TextDirection.rtl,
                    style: kLabelStyle.copyWith(color: kAlertRed),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PIN numpad
          if (!_saving)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _SheetPinNumpad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: kGreen),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SheetPinNumpad — same layout/rules as _PinNumpad in lock_screen.
// Duplicated here to avoid cross-file private access.
// ─────────────────────────────────────────────────────────────────────────────

class _SheetPinNumpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _SheetPinNumpad({
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row(context, ['1', '2', '3']),
        const SizedBox(height: 4),
        _row(context, ['4', '5', '6']),
        const SizedBox(height: 4),
        _row(context, ['7', '8', '9']),
        const SizedBox(height: 4),
        _row(context, ['', '0', '⌫']),
      ],
    );
  }

  Widget _row(BuildContext context, List<String> keys) {
    return Row(
      children: keys
          .expand((k) => [
                Expanded(child: _key(context, k)),
                if (k != keys.last) const SizedBox(width: 4),
              ])
          .toList(),
    );
  }

  Widget _key(BuildContext context, String label) {
    if (label.isEmpty) return const SizedBox(height: 56);

    final isBackspace = label == '⌫';

    return Material(
      color: kSurfaceGray,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          HapticFeedback.selectionClick();
          if (isBackspace) {
            onBackspace();
          } else {
            onDigit(label);
          }
        },
        child: SizedBox(
          height: 56,
          child: Center(
            child: isBackspace
                ? const Icon(Icons.backspace_outlined,
                    size: 24, color: kInkBlack)
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 26,
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

// ─── Language selector ────────────────────────────────────────────────────────
//
// Four segmented buttons (English / Punjabi / Hindi / Urdu).
// Tapping a button writes to SettingsRepository and invalidates languageProvider
// in app.dart — locale changes without app restart.

class _LanguageSelector extends StatelessWidget {
  final String currentCode;
  final Future<void> Function(String code) onSelect;

  const _LanguageSelector({
    required this.currentCode,
    required this.onSelect,
  });

  static const _langs = [
    ('en', 'English'),
    ('hi', 'हिंदी'),
    ('pa', 'ਪੰਜਾਬੀ'),
    ('ur', 'اردو'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: _langs.map((entry) {
          final (code, label) = entry;
          final selected = code == currentCode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                height: kInputHeight,
                decoration: BoxDecoration(
                  color: selected ? kGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [BoxShadow(color: kGreen.withOpacity(0.25), blurRadius: 6)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: kBodyStyle.copyWith(
                      color: selected ? kWhite : kMutedGray,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: code == 'ur' ? 16 : 14,
                      fontFamily: code == 'ur' ? 'NotoNastaliqUrdu' : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String currentMode;
  final Future<void> Function(String mode) onSelect;

  const _ThemeSelector({
    required this.currentMode,
    required this.onSelect,
  });

  static const _modes = [
    ('system', 'System'),
    ('light', 'Light'),
    ('dark', 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: _modes.map((entry) {
          final (mode, label) = entry;
          final selected = mode == currentMode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                height: kInputHeight,
                decoration: BoxDecoration(
                  color: selected ? kGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [BoxShadow(color: kGreen.withOpacity(0.25), blurRadius: 6)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: kBodyStyle.copyWith(
                      color: selected ? kWhite : kMutedGray,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCream,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Container(
          height: subtitle != null ? 72 : kListRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: kSurfaceGray, width: 1),
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: kGreen, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textDirection: TextDirection.rtl,
                      style: kBodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kInkBlack,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textDirection: TextDirection.rtl,
                        style: kBodyStyle.copyWith(
                          fontSize: 13,
                          color: kMutedGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: kGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: kLabelStyle.copyWith(
          color: kMittiBrown,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = danger ? kAlertRed : kInkBlack;
    final iconColor  = danger ? kAlertRed : kGreen;

    return Material(
      color: kCream,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: subtitle != null ? 72 : kListRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: kSurfaceGray, width: 1),
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textDirection: TextDirection.rtl,
                      style: kBodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textDirection: TextDirection.rtl,
                        style: kBodyStyle.copyWith(
                          fontSize: 13,
                          color: kMutedGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left, color: kMutedGray, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
