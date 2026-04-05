import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../db/settings_repository.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LockScreen — app entry gate.
//
// Routing logic (_checkAndRoute):
//   1. isFirstLaunchDone = false  → /onboarding
//   2. getPinHash = null           → /home   (PIN is optional, never set)
//   3. getPinHash = <hash>         → show _PinPadView (4-digit entry)
//
// _PinPadView:
//   - 4 dot indicators (filled = digit entered)
//   - Custom PIN numpad (digits + backspace, NO decimal key)
//   - 4-digit auto-submit (no confirm button — spec requirement)
//   - Wrong PIN → shake animation + HapticFeedback.selectionClick() + clear
//   - Correct PIN → context.go('/home')
// ─────────────────────────────────────────────────────────────────────────────

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _checking = true;
  String? _storedHash;

  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  Future<void> _checkAndRoute() async {
    final isOnboardingDone =
        await SettingsRepository.instance.isFirstLaunchDone();
    if (!mounted) return;

    if (!isOnboardingDone) {
      context.go('/onboarding');
      return;
    }

    final hash = await SettingsRepository.instance.getPinHash();
    if (!mounted) return;

    if (hash == null) {
      context.go('/home');
      return;
    }

    // PIN is set — show PIN pad instead of routing immediately.
    setState(() {
      _storedHash = hash;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: kCream,
        body: Center(child: CircularProgressIndicator(color: kGreen)),
      );
    }
    return _PinPadView(storedHash: _storedHash!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PinPadView — 4-digit PIN entry screen.
// ─────────────────────────────────────────────────────────────────────────────

class _PinPadView extends StatefulWidget {
  final String storedHash;
  const _PinPadView({required this.storedHash});

  @override
  State<_PinPadView> createState() => _PinPadViewState();
}

class _PinPadViewState extends State<_PinPadView>
    with SingleTickerProviderStateMixin {
  String _input = '';

  late final AnimationController _shakeCtrl;
  late final Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Shake: left → right → left → center, three beats.
    _shakeAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(-0.05, 0), end: const Offset(0.03, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: const Offset(0.03, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── INPUT HANDLING ─────────────────────────────────────────────────────────

  void _onDigit(String digit) {
    if (_input.length >= 4) return;
    final next = _input + digit;
    setState(() => _input = next);
    if (next.length == 4) {
      // Auto-submit — spec: no confirm button.
      _verify(next);
    }
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _verify(String pin) {
    final hash = sha256.convert(utf8.encode(pin)).toString();
    if (hash == widget.storedHash) {
      context.go('/home');
    } else {
      // Wrong PIN — shake + clear.
      HapticFeedback.selectionClick();
      _shakeCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _input = '');
      });
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // App name
            const Text(
              'DoodHisaab',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: kGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter PIN',
              style: kBodyStyle.copyWith(color: kMutedGray, fontSize: 15),
            ),

            const Spacer(flex: 1),

            // 4 dot indicators — animated with shake.
            SlideTransition(
              position: _shakeAnim,
              child: _DotIndicators(filledCount: _input.length),
            ),

            const Spacer(flex: 2),

            // PIN numpad — digits only, no decimal key.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _PinNumpad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DotIndicators — 4 circles, filled when digit is entered.
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicators extends StatelessWidget {
  final int filledCount;
  const _DotIndicators({required this.filledCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? kGreen : Colors.transparent,
            border: Border.all(
              color: filled ? kGreen : kMutedGray,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PinNumpad — digit-only numpad for PIN entry.
//
// Layout:
//   1  2  3
//   4  5  6
//   7  8  9
//   ·  0  ⌫   (left cell is a spacer — no decimal key)
//
// Uses InkWell + Material — same as NumpadWidget (ripple feedback required).
// Uses HapticFeedback.selectionClick() — NOT mediumImpact() (API 24 target).
// ─────────────────────────────────────────────────────────────────────────────

class _PinNumpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _PinNumpad({
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
    // Empty string = spacer cell (bottom-left), no interaction.
    if (label.isEmpty) {
      return const SizedBox(height: 64);
    }

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
          height: 64,
          child: Center(
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 26,
                    color: kInkBlack,
                  )
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
