import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DoodhisaabSplashScreen extends StatelessWidget {
  const DoodhisaabSplashScreen({super.key});

  static const _logoAsset = 'assets/icon/doodhisaab_logo.png';
  static const _backgroundAsset = 'assets/images/splash_background.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
              return Image.asset(
                _backgroundAsset,
                fit: BoxFit.cover,
                cacheWidth: (constraints.maxWidth * dpr).round(),
                cacheHeight: (constraints.maxHeight * dpr).round(),
                filterQuality: FilterQuality.low,
              );
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x660F3D26),
                  Color(0x552D1D08),
                  Color(0xAA1A1A1A),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 240),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xEAFBF8F1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xCCFFFFFF),
                        width: 1.2,
                      ),
                    ),
                    child: Image.asset(
                      _logoAsset,
                      fit: BoxFit.contain,
                      semanticLabel: 'Doodhisaab logo',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Doodhisaab',
                    textAlign: TextAlign.center,
                    style: kHeadlineStyle.copyWith(
                      color: kWhite,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Milk Accountant for the farm day ahead',
                    textAlign: TextAlign.center,
                    style: kBodyStyle.copyWith(
                      color: const Color(0xFFF8ECD4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _MilkDropLoader(),
                  const SizedBox(height: 14),
                  Text(
                    'Preparing ledgers, routes, and records...',
                    textAlign: TextAlign.center,
                    style: kBodyStyle.copyWith(
                      color: const Color(0xFFF8ECD4),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilkDropLoader extends StatefulWidget {
  const _MilkDropLoader();

  @override
  State<_MilkDropLoader> createState() => _MilkDropLoaderState();
}

class _MilkDropLoaderState extends State<_MilkDropLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final phase = (_controller.value + index * 0.18) % 1.0;
            final scale = 0.82 + (math.sin(phase * math.pi * 2) + 1) * 0.14;
            final lift = math.cos(phase * math.pi * 2) * 8;

            final colors = <Color>[
              const Color(0xFFF8F6EF),
              const Color(0xFFE0A844),
              kGreen,
            ];

            return Transform.translate(
              offset: Offset(0, -lift),
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 24,
                    color: colors[index],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
