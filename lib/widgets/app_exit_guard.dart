import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppExitGuard extends StatelessWidget {
  final Widget child;

  const AppExitGuard({super.key, required this.child});

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCream,
        title: const Text(
          'Exit app?',
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Yes will close DoodHisaab. Cancel will keep the app open.',
          style: TextStyle(color: kMutedGray, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return shouldExit == true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _confirmExit(context)) {
          await SystemNavigator.pop();
        }
        return false;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (await _confirmExit(context)) {
            await SystemNavigator.pop();
          }
        },
        child: child,
      ),
    );
  }
}
