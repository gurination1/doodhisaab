import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Handles copying the SQLite file to a user-visible backup directory.
///
/// All public methods are intentionally public — [WorkManagerSetup]'s
/// [callbackDispatcher] runs in a separate Dart isolate and cannot access
/// private members across file boundaries.
class BackupService {
  BackupService._();

  static const String _dbName = 'doodhisaab.db';
  static const String _backupFolder = 'DoodHisaab';
  static const int _keepCount = 7;

  // ---------------------------------------------------------------------------
  // Public helpers (called from both main isolate and WorkManager isolate)
  // ---------------------------------------------------------------------------

  /// Returns (and creates if needed) the public Downloads/DoodHisaab/ dir.
  ///
  /// Uses [getDownloadsDirectory()] — visible in the Files app and NOT deleted
  /// on uninstall.  Do NOT use [getExternalStorageDirectory()] — that is
  /// app-private and invisible to the user.
  static Future<Directory> getBackupDir() async {
    final downloads = await getDownloadsDirectory();
    if (downloads == null) {
      throw StateError('No Downloads directory available on this device.');
    }
    final dir = Directory(p.join(downloads.path, _backupFolder));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Keeps the 7 most recent backups; deletes older files by name (ascending
  /// sort — ISO-prefixed filenames sort chronologically).
  ///
  /// Public so [callbackDispatcher] (separate isolate) can call it directly.
  static Future<void> pruneOldBackups(Directory dir) async {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.extension(f.path) == '.db')
        .toList()
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    if (files.length > _keepCount) {
      final toDelete = files.sublist(0, files.length - _keepCount);
      for (final f in toDelete) {
        try {
          await f.delete();
        } catch (_) {
          // Best-effort — don't crash if a file is locked or already gone.
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Main-isolate backup
  // ---------------------------------------------------------------------------

  /// Copies the live SQLite file to the backup directory.
  ///
  /// Returns the newly created backup [File].
  /// Prunes old backups automatically after the copy succeeds.
  ///
  /// Must only be called from the main isolate — it reads the DB path via
  /// [getDatabasesPath()] which requires the main isolate's method channel.
  static Future<File> backupNow() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    final source = File(dbPath);

    if (!source.existsSync()) {
      throw StateError('Database file not found at $dbPath');
    }

    final dir = await getBackupDir();
    final stamp = _timestamp();
    final dest = File(p.join(dir.path, 'doodhisaab_$stamp.db'));

    await source.copy(dest.path);
    await pruneOldBackups(dir);

    return dest;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Produces a timestamp string like `20260403_1430`.
  static String _timestamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final mo = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final mi = now.minute.toString().padLeft(2, '0');
    return '${y}${mo}${d}_$h$mi';
  }
}
