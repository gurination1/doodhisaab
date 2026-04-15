import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      AnalyticsService.instance.trackFeatureUsed(
        featureName: 'tutorial_opened',
        screenName: 'Tutorial',
        routeName: '/tutorial',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.tutorialTitle,
          style: const TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: kInkBlack),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _TutorialCard(
            icon: Icons.home_outlined,
            title: l10n.tutorialHomeTitle,
            body: l10n.tutorialHomeBody,
          ),
          const SizedBox(height: 14),
          _TutorialCard(
            icon: Icons.local_shipping_outlined,
            title: l10n.tutorialDeliveryTitle,
            body: l10n.tutorialDeliveryBody,
          ),
          const SizedBox(height: 14),
          _TutorialCard(
            icon: Icons.save_alt_outlined,
            title: l10n.tutorialSaveTitle,
            body: l10n.tutorialSaveBody,
          ),
          const SizedBox(height: 14),
          _TutorialCard(
            icon: Icons.bar_chart_outlined,
            title: l10n.tutorialReportsTitle,
            body: l10n.tutorialReportsBody,
          ),
          const SizedBox(height: 14),
          _TutorialCard(
            icon: Icons.settings_outlined,
            title: l10n.tutorialSettingsTitle,
            body: l10n.tutorialSettingsBody,
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TutorialCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSurfaceGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kInkBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: kMutedGray,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
