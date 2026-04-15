import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/delivery.dart';
import 'db_provider.dart';

/// Delivery write operations for the entry session flow.
///
/// Read operations (statements, today's list) live in [StatementRepository]
/// to keep concerns separated.
///
/// Balance update contract — delivery_repository does NOT touch cached_balance.
/// The caller ([_DeliveryEntryState._doSaveAll]) calls
/// [CustomerRepository.adjustCachedBalance] after [confirmSession].
///
/// UPSERT strategy:
///   [upsertSessionDraft] reuses the existing delivery_id if a draft for the
///   same (session_id, customer_id) already exists. The INSERT OR REPLACE then
///   overwrites that row — no duplicate rows, no double-billing.
class DeliveryRepository {
  final _uuid = const Uuid();

  // ── Session drafts ─────────────────────────────────────────────────────────

  /// Returns the existing session_draft for (sessionId, customerId), or null.
  ///
  /// Used by [upsertSessionDraft] to decide whether to reuse a delivery_id.
  Future<Delivery?> getDraftForCustomer(
    String sessionId,
    String customerId,
  ) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'deliveries',
      where: "session_id = ? AND customer_id = ? AND status = 'session_draft'",
      whereArgs: [sessionId, customerId],
      limit: 1,
    );
    return rows.isEmpty ? null : Delivery.fromMap(rows.first);
  }

  /// UPSERT a session draft.
  ///
  /// - If no draft exists for (sessionId, customerId): inserts a new row.
  /// - If a draft exists: reuses the same delivery_id so INSERT OR REPLACE
  ///   clobbers the existing row. No duplicate records.
  ///
  /// Called on every customer "Confirm" tap — write-on-confirm architecture.
  /// Previous + re-confirm is safe: the old draft is overwritten, not duplicated.
  Future<Delivery> upsertSessionDraft({
    required String sessionId,
    required String customerId,
    required String date,
    required double liters,
    required double pricePerLiter,
    required String deviceId,
  }) async {
    final db = await DatabaseProvider.database;
    final existing = await getDraftForCustomer(sessionId, customerId);

    // totalValue stored as rounded 2-dp to avoid IEEE float drift
    final total = ((liters * pricePerLiter) * 100).round() / 100;

    final delivery = Delivery(
      deliveryId:      existing?.deliveryId ?? _uuid.v4(),
      customerId:      customerId,
      date:            date,
      liters:          liters,
      pricePerLiter:   pricePerLiter,
      totalValue:      total,
      status:          'session_draft',
      sessionId:       sessionId,
      createdByDevice: deviceId,
      syncStatus:      'local',
      // Preserve original createdAt on re-confirm — shows true entry time
      createdAt:       existing?.createdAt ?? DateTime.now().toIso8601String(),
    );

    await db.insert(
      'deliveries',
      delivery.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return delivery;
  }

  /// Promotes all session_draft records for [sessionId] to 'confirmed'.
  ///
  /// Called by SAVE ALL after the user confirms the last customer.
  /// After this call, the caller must update cached_balance for each customer.
  Future<void> confirmSession(String sessionId) async {
    final db = await DatabaseProvider.database;
    await db.update(
      'deliveries',
      {'status': 'confirmed'},
      where: "session_id = ? AND status = 'session_draft'",
      whereArgs: [sessionId],
    );
  }

  /// Marks all drafts for [sessionId] as 'abandoned'.
  ///
  /// Called when the user explicitly discards a session or when crash recovery
  /// is dismissed ("Start Fresh" option).
  /// Abandoned records are excluded from all balance/statement queries.
  Future<void> abandonSession(String sessionId) async {
    final db = await DatabaseProvider.database;
    await db.update(
      'deliveries',
      {'status': 'abandoned'},
      where: "session_id = ? AND status = 'session_draft'",
      whereArgs: [sessionId],
    );
  }

  /// Deletes one customer's draft from the active session.
  ///
  /// Used when the operator clears a mistaken milk entry before final save.
  Future<void> deleteSessionDraftForCustomer(
    String sessionId,
    String customerId,
  ) async {
    final db = await DatabaseProvider.database;
    await db.delete(
      'deliveries',
      where: "session_id = ? AND customer_id = ? AND status = 'session_draft'",
      whereArgs: [sessionId, customerId],
    );
  }

  /// All session_draft records for a given session, ordered by entry time.
  Future<List<Delivery>> getSessionDrafts(String sessionId) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'deliveries',
      where: "session_id = ? AND status = 'session_draft'",
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Delivery.fromMap).toList();
  }

  // ── Crash recovery ─────────────────────────────────────────────────────────

  /// Returns any session_draft records from today for [deviceId] that were
  /// never confirmed or abandoned (i.e. the app crashed mid-session).
  ///
  /// Called in [DeliveryEntryScreen.initState]. If non-empty, a recovery
  /// dialog is shown offering to resume or discard.
  Future<List<Delivery>> getTodayIncompleteDrafts(String deviceId) async {
    final db = await DatabaseProvider.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await db.query(
      'deliveries',
      where: "date = ? AND status = 'session_draft' AND created_by_device = ?",
      whereArgs: [today, deviceId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Delivery.fromMap).toList();
  }
}
