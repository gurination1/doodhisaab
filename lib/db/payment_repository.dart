import 'package:uuid/uuid.dart';

import '../models/payment.dart';
import 'db_provider.dart';

/// Payment write operations.
///
/// Balance update contract — payment_repository does NOT touch cached_balance.
/// The caller ([_PaymentEntryState._doSave]) calls
/// [CustomerRepository.adjustCachedBalance] with a NEGATIVE delta after
/// [insertPayment] returns:
///
///   await _customerRepo.adjustCachedBalance(customerId, -amount);
///
/// Payments reduce the customer's balance (they owe less after paying).
///
/// [insertPayment] always assigns sync_status = 'local' — no cloud sync in MVP.
class PaymentRepository {
  final _uuid = const Uuid();

  // ── WRITE ──────────────────────────────────────────────────────────────────

  /// Inserts a new payment row and returns the persisted [Payment].
  ///
  /// Generates a fresh UUID for [payment_id].
  /// Does NOT update [cached_balance] — caller must call
  /// [CustomerRepository.adjustCachedBalance(customerId, -amount)] immediately.
  Future<Payment> insertPayment({
    required String customerId,
    required String date,
    required double amount,
    required String deviceId,
    String? note,
  }) async {
    final db = await DatabaseProvider.database;

    // Round to 2 dp to prevent IEEE float drift in the ledger
    final roundedAmount = (amount * 100).round() / 100;

    final payment = Payment(
      paymentId:       _uuid.v4(),
      customerId:      customerId,
      date:            date,
      amount:          roundedAmount,
      note:            note?.trim().isEmpty == true ? null : note?.trim(),
      createdByDevice: deviceId,
      syncStatus:      'local',
      createdAt:       DateTime.now().toIso8601String(),
    );

    await db.insert('payments', payment.toMap());
    return payment;
  }

  // ── READ (lightweight — full statement queries live in StatementRepository) ─

  /// Most recent payments for a customer, newest first.
  ///
  /// [limit] defaults to 50 — enough for a customer profile card.
  /// Full history queries belong in [StatementRepository].
  Future<List<Payment>> getRecentPayments(
    String customerId, {
    int limit = 50,
  }) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'payments',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map(Payment.fromMap).toList();
  }
}
