import 'package:uuid/uuid.dart';

import '../models/other_income.dart';
import 'db_provider.dart';

/// Other (non-milk) income data access.
///
/// Appears in the P&L report as additional revenue alongside milk sales.
/// IMPORTANT: The CSV export service (Step 20) queries this table directly.
/// The "OTHER INCOME" section in the export depends on data being present here.
///
/// Valid categories: Calf Sale | Ghee Sale | Manure Sale | Other
///
/// Entry UI rule: category selection via visible chip row, NOT a dropdown.
class OtherIncomeRepository {
  final _uuid = const Uuid();

  // ── READ ──────────────────────────────────────────────────────────────────

  /// All other-income records for a given month, newest first.
  Future<List<OtherIncome>> getMonthlyOtherIncome(int year, int month) async {
    final db     = await DatabaseProvider.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows   = await db.query(
      'other_income',
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'date DESC',
    );
    return rows.map(OtherIncome.fromMap).toList();
  }

  /// Monthly total across all categories.
  Future<double> getMonthlyTotal(int year, int month) async {
    final db     = await DatabaseProvider.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows   = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM other_income WHERE date LIKE ?',
      ['$prefix%'],
    );
    return (rows.first['total'] as num).toDouble();
  }

  // ── WRITE ─────────────────────────────────────────────────────────────────

  /// Records a new other-income entry.
  ///
  /// [date] should be ISO-8601 'YYYY-MM-DD'. Defaults to today.
  /// [category] must be one of [OtherIncome.validCategories].
  Future<OtherIncome> addOtherIncome({
    required String category,
    required double amount,
    String? date,
    String? note,
  }) async {
    assert(
      OtherIncome.validCategories.contains(category),
      'Invalid income category: $category. '
      'Must be one of: ${OtherIncome.validCategories.join(', ')}',
    );

    final db     = await DatabaseProvider.database;
    final today  = date ?? DateTime.now().toIso8601String().substring(0, 10);
    final roundedAmount = (amount * 100).round() / 100;
    final income = OtherIncome(
      incomeId:  _uuid.v4(),
      date:      today,
      category:  category,
      amount:    roundedAmount,
      note:      note,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('other_income', income.toMap());
    return income;
  }

  /// Deletes an other-income record by ID.
  Future<void> deleteOtherIncome(String incomeId) async {
    final db = await DatabaseProvider.database;
    await db.delete(
      'other_income',
      where: 'income_id = ?',
      whereArgs: [incomeId],
    );
  }
}
