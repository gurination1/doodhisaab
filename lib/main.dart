import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/analytics_service.dart';
import 'db/customer_repository.dart';
import 'db/db_provider.dart';
import 'db/settings_repository.dart';
import 'screens/startup/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/workmanager_setup.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
        debugPrintStack(stackTrace: details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('PlatformDispatcher error: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };

      await AnalyticsService.instance.init();
      final deviceId = await SettingsRepository.instance.getDeviceId();
      await AnalyticsService.instance.identifyUser(deviceId);
      await AnalyticsService.instance.trackEvent(
        'app_cold_start',
        properties: const {'entrypoint': 'main'},
      );
      runApp(const ProviderScope(child: _StartupBootstrap()));
    },
    (error, stack) {
      debugPrint('Zone error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class _StartupBootstrap extends StatefulWidget {
  const _StartupBootstrap();

  @override
  State<_StartupBootstrap> createState() => _StartupBootstrapState();
}

class _StartupBootstrapState extends State<_StartupBootstrap> {
  late Future<void> _initializeFuture;
  late final DateTime _splashEnteredAt;
  bool _splashTracked = false;

  @override
  void initState() {
    super.initState();
    _splashEnteredAt = DateTime.now();
    unawaited(
      AnalyticsService.instance.trackScreenView(
        screenName: 'Splash',
        routeName: '/splash',
        screenClass: 'DoodhisaabSplashScreen',
        navigationSource: 'app_start',
      ),
    );
    _initializeFuture = _initialize();
  }

  void _finishSplashTracking(String nextScreenName) {
    if (_splashTracked) return;
    _splashTracked = true;
    unawaited(
      AnalyticsService.instance.trackTimeSpent(
        screenName: 'Splash',
        routeName: '/splash',
        durationMs: DateTime.now().difference(_splashEnteredAt).inMilliseconds,
        nextScreenName: nextScreenName,
      ),
    );
  }

  Future<void> _initialize() async {
    final db = await DatabaseProvider.database;

    assert(() {
      db
          .rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      )
          .then((rows) {
        assert(
          rows.length >= 7,
          'Performance warning: only ${rows.length}/7 required indices found. '
          'Run flutter test to diagnose. Missing indices will cause slow queries.',
        );
      });
      return true;
    }());

    try {
      await CustomerRepository().repairAllBalances();
    } catch (e, st) {
      debugPrint('Balance repair skipped: $e');
      debugPrintStack(stackTrace: st);
    }

    try {
      await WorkManagerSetup.initWorkManager();
      await WorkManagerSetup.registerBackupTask();
    } catch (e, st) {
      debugPrint('WorkManager setup skipped: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  void _retry() {
    setState(() {
      _initializeFuture = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: FutureBuilder<void>(
        key: ValueKey<Object?>(
          _initializeFuture,
        ),
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              key: const ValueKey('startup-loading'),
              debugShowCheckedModeBanner: false,
              home: const DoodhisaabSplashScreen(),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            debugPrint('Startup failed: $error');
            if (snapshot.stackTrace != null) {
              debugPrintStack(stackTrace: snapshot.stackTrace);
            }
            return MaterialApp(
              key: const ValueKey('startup-error'),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: kCream,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: kAlertRed),
                        const SizedBox(height: 16),
                        const Text(
                          'App failed to start',
                          textAlign: TextAlign.center,
                          style: kHeadlineStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: kBodyStyle.copyWith(color: kMutedGray),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _retry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          _finishSplashTracking('Lock');
          return const DoodHisaabApp(key: ValueKey('startup-ready'));
        },
      ),
    );
  }
}
