import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          l10n.settingsPrivacyTerms,
          style: const TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: kInkBlack),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PolicyCard(
            title: l10n.privacySimpleTitle,
            body: l10n.privacySimpleBody,
          ),
          const SizedBox(height: 14),
          _PolicyCard(
            title: l10n.privacyDataTitle,
            body: l10n.privacyDataBody,
          ),
          const SizedBox(height: 14),
          _PolicyCard(
            title: l10n.privacyAnalyticsTitle,
            body: l10n.privacyAnalyticsBody,
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String body;

  const _PolicyCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kSurfaceGray),
      ),
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
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: kMutedGray,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
