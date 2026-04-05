import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const kDbName = 'doodhisaab.db';
const kDbVersion = 2;

/// The only place in the codebase that defines the SQLite schema.
///
/// All tables, all indices, and both PRAGMAs live here.
/// If schema changes, bump [kDbVersion] and add a migration in [_onUpgrade].
///
/// Architecture notes:
/// - WAL mode: each confirmed customer = one committed transaction.
///   Power cut after N confirmations = N records safe, rest missing cleanly.
///   No corruption, no silent data loss.
/// - closeAndReset() is PUBLIC — BackupService and tests both need it.
///   Never access _db directly from other files.
class DatabaseProvider {
  DatabaseProvider._();

  static Database? _db;

  /// Returns the open database, initializing it on first call.
  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  /// Closes the database and clears the singleton.
  ///
  /// Required by:
  ///  - [BackupService]: must close before copying the DB file
  ///  - Tests: each test needs a fresh DB with no stale singleton
  ///
  /// NEVER call _db = null directly from other files — Dart visibility
  /// does not prevent it but it skips the close() call, leaking the
  /// file descriptor on Android.
  static Future<void> closeAndReset() async {
    await _db?.close();
    _db = null;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), kDbName);
    return openDatabase(
      path,
      version: kDbVersion,
      onOpen: _onOpen,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCHEMA CREATION
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _onOpen(Database db) async {
    // WAL mode: safe with NORMAL synchronous on Android flash storage.
    // FULL synchronous with WAL gives no extra safety and doubles write latency.
    await db.rawQuery('PRAGMA journal_mode = WAL;');
    await db.rawQuery('PRAGMA synchronous = NORMAL;');
    await _ensureSchema(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db, ifNotExists: false);
    await _createIndexes(db, ifNotExists: false);
  }

  static Future<void> _createTables(
    Database db, {
    required bool ifNotExists,
  }) async {
    final guard = ifNotExists ? ' IF NOT EXISTS' : '';

    // ── CUSTOMERS ────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE$guard customers (
        customer_id           TEXT PRIMARY KEY,
        name                  TEXT NOT NULL,
        phone                 TEXT,
        address               TEXT,
        default_liters        REAL NOT NULL DEFAULT 2.0,
        payment_cycle         TEXT NOT NULL DEFAULT 'Monthly',
        payment_cycle_days    INTEGER,
        price_override        REAL,
        price_override_reason TEXT,
        route_order           INTEGER NOT NULL DEFAULT 0,
        is_active             INTEGER NOT NULL DEFAULT 1,
        archived_at           TEXT,
        cached_balance        REAL NOT NULL DEFAULT 0.0,
        created_at            TEXT NOT NULL
      )
    ''');

    // ── DELIVERIES ───────────────────────────────────────────────────────────
    // status values: 'session_draft' | 'confirmed' | 'abandoned'
    //
    // Write-on-confirm architecture:
    //   Each customer confirmation INSERTs a 'session_draft' row immediately.
    //   SAVE ALL promotes all drafts to 'confirmed' in a single UPDATE.
    //   If the app is killed mid-session, drafts survive and recovery is possible.
    //
    // session_id: UUID generated once when the delivery entry screen opens.
    //   All rows from one entry session share the same session_id.
    //   Used to detect and recover incomplete sessions on next app open.
    await db.execute('''
      CREATE TABLE$guard deliveries (
        delivery_id       TEXT PRIMARY KEY,
        customer_id       TEXT NOT NULL,
        date              TEXT NOT NULL,
        liters            REAL NOT NULL,
        price_per_liter   REAL NOT NULL,
        total_value       REAL NOT NULL,
        note              TEXT,
        status            TEXT NOT NULL DEFAULT 'session_draft',
        session_id        TEXT,
        created_by_device TEXT NOT NULL,
        sync_status       TEXT NOT NULL DEFAULT 'local',
        created_at        TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
      )
    ''');

    // ── PAYMENTS ─────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE$guard payments (
        payment_id        TEXT PRIMARY KEY,
        customer_id       TEXT NOT NULL,
        date              TEXT NOT NULL,
        amount            REAL NOT NULL,
        note              TEXT,
        created_by_device TEXT NOT NULL,
        sync_status       TEXT NOT NULL DEFAULT 'local',
        created_at        TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
      )
    ''');

    // ── PRICE HISTORY ─────────────────────────────────────────────────────────
    // Stores every milk price change with the date it took effect.
    // Used to calculate historical delivery values correctly when editing past records.
    await db.execute('''
      CREATE TABLE$guard price_history (
        price_id        TEXT PRIMARY KEY,
        price_per_liter REAL NOT NULL,
        effective_from  TEXT NOT NULL,
        note            TEXT
      )
    ''');

    // ── EXPENSES ─────────────────────────────────────────────────────────────
    // categories: Feed | Medicine | Fuel | Electricity | Labor | Other
    await db.execute('''
      CREATE TABLE$guard expenses (
        expense_id TEXT PRIMARY KEY,
        date       TEXT NOT NULL,
        category   TEXT NOT NULL,
        amount     REAL NOT NULL,
        note       TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // ── OTHER INCOME ──────────────────────────────────────────────────────────
    // categories: Calf Sale | Ghee Sale | Manure Sale | Other
    // IMPORTANT: This table is included in CSV export (Step 20).
    // Do not remove it — the export service queries it by name.
    await db.execute('''
      CREATE TABLE$guard other_income (
        income_id  TEXT PRIMARY KEY,
        date       TEXT NOT NULL,
        category   TEXT NOT NULL,
        amount     REAL NOT NULL,
        note       TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // ── DELIVERY EDIT LOG ─────────────────────────────────────────────────────
    // Audit trail. Every edit to a confirmed delivery appends a row here.
    // Farmer can review if a customer disputes a quantity after the fact.
    await db.execute('''
      CREATE TABLE$guard delivery_edit_log (
        log_id      TEXT PRIMARY KEY,
        delivery_id TEXT NOT NULL,
        old_liters  REAL NOT NULL,
        new_liters  REAL NOT NULL,
        reason      TEXT,
        edited_at   TEXT NOT NULL,
        edited_by   TEXT NOT NULL
      )
    ''');

    // ── APP SETTINGS ──────────────────────────────────────────────────────────
    // Simple key-value store. One row per setting.
    // Known keys: device_id | language | app_version |
    //             first_launch_done | outdoor_mode | pin_hash
    await db.execute('''
      CREATE TABLE$guard app_settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createIndexes(
    Database db, {
    required bool ifNotExists,
  }) async {
    final guard = ifNotExists ? ' IF NOT EXISTS' : '';

    // ── INDICES (7 total) ─────────────────────────────────────────────────────
    //
    // Verify all 7 exist at startup by checking sqlite_master:
    //   SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';
    //
    // Customer list — most frequent query in entire app (every screen open)
    await db.execute(
        'CREATE INDEX$guard idx_cust_active_route ON customers(is_active, route_order ASC)');
    //
    // Delivery queries — per-customer monthly statements
    await db.execute(
        'CREATE INDEX$guard idx_del_cust_date ON deliveries(customer_id, date DESC)');
    //
    // Delivery queries — farm-wide daily / monthly totals
    await db.execute(
        'CREATE INDEX$guard idx_del_date ON deliveries(date DESC)');
    //
    // Payment queries — per-customer history and overdraft check
    await db.execute(
        'CREATE INDEX$guard idx_pay_cust_date ON payments(customer_id, date DESC)');
    //
    // Edit history — per-delivery audit lookup
    await db.execute(
        'CREATE INDEX$guard idx_edit_delivery ON delivery_edit_log(delivery_id)');
    //
    // Price history — find the price in effect on any historical date
    await db.execute(
        'CREATE INDEX$guard idx_price_from ON price_history(effective_from DESC)');
    //
    // Other income — monthly totals for P&L report
    await db.execute(
        'CREATE INDEX$guard idx_income_date ON other_income(date DESC)');
  }

  static Future<void> _ensureSchema(Database db) async {
    await _createTables(db, ifNotExists: true);
    await _ensureColumns(db, 'customers', const {
      'customer_id': "TEXT PRIMARY KEY",
      'name': "TEXT NOT NULL DEFAULT ''",
      'phone': 'TEXT',
      'address': 'TEXT',
      'default_liters': 'REAL NOT NULL DEFAULT 2.0',
      'payment_cycle': "TEXT NOT NULL DEFAULT 'Monthly'",
      'payment_cycle_days': 'INTEGER',
      'price_override': 'REAL',
      'price_override_reason': 'TEXT',
      'route_order': 'INTEGER NOT NULL DEFAULT 0',
      'is_active': 'INTEGER NOT NULL DEFAULT 1',
      'archived_at': 'TEXT',
      'cached_balance': 'REAL NOT NULL DEFAULT 0.0',
      'created_at': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'deliveries', const {
      'delivery_id': "TEXT PRIMARY KEY",
      'customer_id': "TEXT NOT NULL DEFAULT ''",
      'date': "TEXT NOT NULL DEFAULT ''",
      'liters': 'REAL NOT NULL DEFAULT 0',
      'price_per_liter': 'REAL NOT NULL DEFAULT 0',
      'total_value': 'REAL NOT NULL DEFAULT 0',
      'note': 'TEXT',
      'status': "TEXT NOT NULL DEFAULT 'session_draft'",
      'session_id': 'TEXT',
      'created_by_device': "TEXT NOT NULL DEFAULT ''",
      'sync_status': "TEXT NOT NULL DEFAULT 'local'",
      'created_at': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'payments', const {
      'payment_id': "TEXT PRIMARY KEY",
      'customer_id': "TEXT NOT NULL DEFAULT ''",
      'date': "TEXT NOT NULL DEFAULT ''",
      'amount': 'REAL NOT NULL DEFAULT 0',
      'note': 'TEXT',
      'created_by_device': "TEXT NOT NULL DEFAULT ''",
      'sync_status': "TEXT NOT NULL DEFAULT 'local'",
      'created_at': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'price_history', const {
      'price_id': "TEXT PRIMARY KEY",
      'price_per_liter': 'REAL NOT NULL DEFAULT 0',
      'effective_from': "TEXT NOT NULL DEFAULT ''",
      'note': 'TEXT',
    });
    await _ensureColumns(db, 'expenses', const {
      'expense_id': "TEXT PRIMARY KEY",
      'date': "TEXT NOT NULL DEFAULT ''",
      'category': "TEXT NOT NULL DEFAULT ''",
      'amount': 'REAL NOT NULL DEFAULT 0',
      'note': 'TEXT',
      'created_at': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'other_income', const {
      'income_id': "TEXT PRIMARY KEY",
      'date': "TEXT NOT NULL DEFAULT ''",
      'category': "TEXT NOT NULL DEFAULT ''",
      'amount': 'REAL NOT NULL DEFAULT 0',
      'note': 'TEXT',
      'created_at': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'delivery_edit_log', const {
      'log_id': "TEXT PRIMARY KEY",
      'delivery_id': "TEXT NOT NULL DEFAULT ''",
      'old_liters': 'REAL NOT NULL DEFAULT 0',
      'new_liters': 'REAL NOT NULL DEFAULT 0',
      'reason': 'TEXT',
      'edited_at': "TEXT NOT NULL DEFAULT ''",
      'edited_by': "TEXT NOT NULL DEFAULT ''",
    });
    await _ensureColumns(db, 'app_settings', const {
      'key': "TEXT PRIMARY KEY",
      'value': "TEXT NOT NULL DEFAULT ''",
    });
    await _createIndexes(db, ifNotExists: true);
  }

  static Future<void> _ensureColumns(
    Database db,
    String table,
    Map<String, String> columns,
  ) async {
    final info = await db.rawQuery("PRAGMA table_info($table)");
    final existing = info
        .map((row) => row['name'])
        .whereType<String>()
        .toSet();

    for (final entry in columns.entries) {
      if (existing.contains(entry.key)) continue;
      await db.execute(
        'ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MIGRATIONS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _ensureSchema(db);
  }
}
