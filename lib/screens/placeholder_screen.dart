import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlaceholderScreen
//
// Shows a simple AppBar + centered "آنے والا" (Coming Soon) message.
// Used for routes that are declared in the router (so taps don't crash) but
// whose real screen has not been built yet in this step.
// ─────────────────────────────────────────────────────────────────────────────

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: const BackButton(color: kInkBlack),
        title: Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'آنے والا',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: kMutedGray, fontSize: 20),
        ),
      ),
    );
  }
}
