import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'db/customer_repository.dart';
import 'db/db_provider.dart';
import 'theme/app_theme.dart';
import 'services/workmanager_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _StartupBootstrap()));
}

class _StartupBootstrap extends StatefulWidget {
  const _StartupBootstrap();

  @override
  State<_StartupBootstrap> createState() => _StartupBootstrapState();
}

class _StartupBootstrapState extends State<_StartupBootstrap> {
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initialize();
  }

  Future<void> _initialize() async {
    final db = await DatabaseProvider.database;

    assert(() {
      db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      ).then((rows) {
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
    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: kCream,
              body: const Center(
                child: CircularProgressIndicator(color: kGreen),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          debugPrint('Startup failed: $error');
          if (snapshot.stackTrace != null) {
            debugPrintStack(stackTrace: snapshot.stackTrace);
          }
          return MaterialApp(
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
                      const Icon(Icons.error_outline, size: 56, color: kAlertRed),
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

        return const DoodHisaabApp();
      },
    );
  }
}
