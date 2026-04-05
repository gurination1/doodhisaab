import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import 'backup_service.dart';

/// Unique task name registered with WorkManager.
const String kBackupTask = 'doodhisaab_backup';

/// Top-level callback required by WorkManager.
///
/// IMPORTANT: This runs in a **separate Dart isolate**.
/// - The SQLite singleton (`DatabaseProvider._db`) is invisible here.
/// - Do NOT call DatabaseProvider, sqflite open/query, or any method that
///   touches the DB through the normal singleton.
/// - This is a raw file copy only.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != kBackupTask) return Future.value(true);

    try {
      // --- File copy only — NO sqflite calls ---
      const dbName = 'doodhisaab.db';
      final dbPath = p.join(await getDatabasesPath(), dbName);
      final source = File(dbPath);

      if (!source.existsSync()) {
        // DB doesn't exist yet (first install, no data). Not an error.
        return Future.value(true);
      }

      final dir = await BackupService.getBackupDir();
      final now = DateTime.now();
      final stamp =
          '${now.year.toString().padLeft(4, '0')}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}';

      final dest = File(p.join(dir.path, 'doodhisaab_$stamp.db'));
      await source.copy(dest.path);

      // Prune old backups — public method, safe from any isolate.
      await BackupService.pruneOldBackups(dir);

      return Future.value(true);
    } catch (_) {
      // WorkManager retries on false; returning true prevents infinite retry
      // storms for transient errors (e.g. storage temporarily unavailable).
      return Future.value(true);
    }
  });
}

/// Encapsulates all WorkManager wiring so [main.dart] stays clean.
class WorkManagerSetup {
  WorkManagerSetup._();

  /// Call once in [main()] — registers the [callbackDispatcher] with the OS.
  static Future<void> initWorkManager() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Schedules a daily backup task.
  ///
  /// [registerPeriodicTask] is idempotent when the unique name is the same —
  /// safe to call on every cold start.
  ///
  /// `requiresBatteryNotLow: true` — prevents the backup from running when the
  /// battery is already dying (architecture decision — see DEV_CONTEXT).
  static Future<void> registerBackupTask() async {
    await Workmanager().registerPeriodicTask(
      kBackupTask,
      kBackupTask,
      frequency: const Duration(days: 1),
      constraints: Constraints(
        requiresBatteryNotLow: true,
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
