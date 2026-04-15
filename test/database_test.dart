import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:doodhisaab/db/db_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    // Use in-memory SQLite for tests — no Android emulator needed.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseProvider.dbNameOverrideForTesting = 'doodhisaab_database_test.db';
  });

  setUp(() async {
    // Reset singleton between tests — required.
    // Without this, tests share the same DB instance and interfere.
    await DatabaseProvider.closeAndReset();
    final path = p.join(
      await getDatabasesPath(),
      DatabaseProvider.dbNameOverrideForTesting ?? kDbName,
    );
    await deleteDatabase(path);
  });

  group('DatabaseProvider', () {
    test('creates database without error', () async {
      final db = await DatabaseProvider.database;
      expect(db.isOpen, isTrue);
    });

    test('all 8 tables exist', () async {
      final db = await DatabaseProvider.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final names = tables.map((r) => r['name'] as String).toSet();
      expect(names, containsAll({
        'customers',
        'deliveries',
        'payments',
        'price_history',
        'expenses',
        'other_income',
        'delivery_edit_log',
        'app_settings',
      }));
    });

    test('all 7 indices exist', () async {
      final db = await DatabaseProvider.database;
      final indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%' ORDER BY name",
      );
      final names = indices.map((r) => r['name'] as String).toSet();
      expect(names, containsAll({
        'idx_cust_active_route',
        'idx_del_cust_date',
        'idx_del_date',
        'idx_pay_cust_date',
        'idx_edit_delivery',
        'idx_price_from',
        'idx_income_date',
      }));
    });

    test('closeAndReset allows fresh DB open', () async {
      final db1 = await DatabaseProvider.database;
      expect(db1.isOpen, isTrue);

      await DatabaseProvider.closeAndReset();

      // After reset, a new call returns a fresh open instance.
      final db2 = await DatabaseProvider.database;
      expect(db2.isOpen, isTrue);
    });

    test('WAL mode is enabled', () async {
      final db = await DatabaseProvider.database;
      final result = await db.rawQuery('PRAGMA journal_mode;');
      expect(result.first['journal_mode'], equals('wal'));
    });
  });
}
