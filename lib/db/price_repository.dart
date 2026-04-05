import 'package:uuid/uuid.dart';

import '../models/price_history.dart';
import 'db_provider.dart';

/// Milk price history data access.
///
/// The "current price" is always the row with the most recent [effective_from].
/// Uses idx_price_from index for all queries — O(log n).
///
/// Price change workflow:
///   1. Farmer sets new price in Settings or Onboarding
///   2. [setPrice] inserts a new row with today's date as effective_from
///   3. All future deliveries use the new price
///   4. Historical deliveries keep their stored [price_per_liter] — never recomputed
///
/// The 30-day stale banner (shown in delivery entry) is triggered when:
///   DateTime.now().difference(DateTime.parse(currentRow.effectiveFrom)).inDays > 30
class PriceRepository {
  final _uuid = const Uuid();

  // ── READ ──────────────────────────────────────────────────────────────────

  /// Returns the current price per liter.
  /// Uses idx_price_from — fastest possible lookup.
  /// Returns 0.0 if no price has ever been set (pre-onboarding state).
  Future<double> getCurrentPrice() async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'price_history',
      orderBy: 'effective_from DESC',
      limit: 1,
    );
    if (rows.isEmpty) return 0.0;
    return (rows.first['price_per_liter'] as num).toDouble();
  }

  /// Returns the full current price_history row, including [effectiveFrom].
  /// Used to check whether the stale-price banner should be shown.
  /// Returns null if no price has ever been set.
  Future<PriceHistory?> getCurrentPriceRow() async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'price_history',
      orderBy: 'effective_from DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PriceHistory.fromMap(rows.first);
  }

  /// Returns the price that was in effect on [date] (ISO-8601 'YYYY-MM-DD').
  ///
  /// Used when editing a historical delivery — the price used at that time
  /// must be reapplied so the total_value remains accurate.
  ///
  /// Falls back to [getCurrentPrice] if no price row predates [date].
  Future<double> getPriceForDate(String date) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'price_history',
      where: 'effective_from <= ?',
      whereArgs: [date],
      orderBy: 'effective_from DESC',
      limit: 1,
    );
    if (rows.isEmpty) return getCurrentPrice();
    return (rows.first['price_per_liter'] as num).toDouble();
  }

  /// Full price history, newest first.
  /// Used by the Settings → Price History list.
  Future<List<PriceHistory>> getHistory() async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'price_history',
      orderBy: 'effective_from DESC',
    );
    return rows.map(PriceHistory.fromMap).toList();
  }

  /// True if the current price is older than [days] days.
  /// Delivery entry screen shows the stale-price banner when this is true.
  Future<bool> isPriceStale({int days = 30}) async {
    final row = await getCurrentPriceRow();
    if (row == null) return false; // no price set yet — banner not relevant
    final age = DateTime.now().difference(DateTime.parse(row.effectiveFrom)).inDays;
    return age > days;
  }

  // ── WRITE ─────────────────────────────────────────────────────────────────

  /// Records a new milk price effective from today.
  ///
  /// Does NOT modify historical delivery rows — those keep their stored price.
  /// All deliveries confirmed after this call use the new price.
  Future<PriceHistory> setPrice(double pricePerLiter, {String? note}) async {
    final db = await DatabaseProvider.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final row = PriceHistory(
      priceId:       _uuid.v4(),
      pricePerLiter: pricePerLiter,
      effectiveFrom: today,
      note:          note,
    );
    await db.insert('price_history', row.toMap());
    return row;
  }
}
