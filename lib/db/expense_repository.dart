import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import 'db_provider.dart';

/// Expense data access.
///
/// Expenses appear in the P&L report as cost deductions.
/// Valid categories: Feed | Medicine | Fuel | Electricity | Labor | Other
///
/// Entry UI rule: category selection via visible chip row, NOT a dropdown.
/// Dropdowns have low discoverability for low-literacy users.
class ExpenseRepository {
  final _uuid = const Uuid();

  // ── READ ──────────────────────────────────────────────────────────────────

  /// All expenses for a given month, newest first.
  /// Uses idx_del_date-compatible pattern (LIKE prefix on date column).
  Future<List<Expense>> getMonthlyExpenses(int year, int month) async {
    final db     = await DatabaseProvider.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows   = await db.query(
      'expenses',
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Monthly total, broken down by category.
  ///
  /// Returns a map of category → total amount.
  /// Categories with zero spend are not included.
  Future<Map<String, double>> getMonthlyCategoryTotals(int year, int month) async {
    final db     = await DatabaseProvider.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows   = await db.rawQuery(
      'SELECT category, COALESCE(SUM(amount), 0) as total '
      "FROM expenses WHERE date LIKE ? GROUP BY category",
      ['$prefix%'],
    );
    return {
      for (final r in rows)
        r['category'] as String: (r['total'] as num).toDouble()
    };
  }

  // ── WRITE ─────────────────────────────────────────────────────────────────

  /// Records a new expense.
  ///
  /// [date] should be ISO-8601 'YYYY-MM-DD'. Defaults to today.
  /// [category] must be one of [Expense.validCategories].
  Future<Expense> addExpense({
    required String category,
    required double amount,
    String? date,
    String? note,
  }) async {
    assert(
      Expense.validCategories.contains(category),
      'Invalid expense category: $category. '
      'Must be one of: ${Expense.validCategories.join(', ')}',
    );

    final db      = await DatabaseProvider.database;
    final today   = date ?? DateTime.now().toIso8601String().substring(0, 10);
    final expense = Expense(
      expenseId: _uuid.v4(),
      date:      today,
      category:  category,
      amount:    amount,
      note:      note,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('expenses', expense.toMap());
    return expense;
  }

  /// Deletes an expense by ID.
  Future<void> deleteExpense(String expenseId) async {
    final db = await DatabaseProvider.database;
    await db.delete(
      'expenses',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
  }
}
