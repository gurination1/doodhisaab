import '../models/customer_statement.dart';
import '../models/delivery.dart';
import '../models/monthly_summary.dart';
import '../models/payment.dart';
import 'db_provider.dart';

/// Statement and summary queries.
///
/// ⚠️  STUB — implementations are placeholders.
///     Full implementation: Step 10 / Step 16 (Reports).
///     Do not remove or rename methods — providers depend on these exact signatures.
///
/// Architecture: ALL methods must be called on the MAIN ISOLATE via FutureBuilder.
/// sqflite's MethodChannel is bound to the main isolate.
/// Never pass these calls to Isolate.run() — it will throw at runtime.
class StatementRepository {
  // ── CUSTOMER STATEMENT ───────────────────────────────────────────────────────

  /// Returns a monthly statement for one customer.
  /// Queries confirmed deliveries and all payments for [customerId]
  /// in the given [year]/[month].
  Future<CustomerStatement> getCustomerStatement(
    String customerId,
    int year,
    int month,
  ) async {
    // TODO(Step 16): full implementation
    final db = await DatabaseProvider.database;

    final monthStr = month.toString().padLeft(2, '0');
    final prefix   = '$year-$monthStr';

    final deliveryRows = await db.query(
      'deliveries',
      where: "customer_id = ? AND date LIKE ? AND status = 'confirmed'",
      whereArgs: [customerId, '$prefix%'],
      orderBy: 'date ASC',
    );
    final paymentRows = await db.query(
      'payments',
      where: 'customer_id = ? AND date LIKE ?',
      whereArgs: [customerId, '$prefix%'],
      orderBy: 'date ASC',
    );

    final customerRow = await db.query(
      'customers',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      limit: 1,
    );
    final customerName = customerRow.isEmpty
        ? ''
        : customerRow.first['name'] as String;

    return CustomerStatement.fromLists(
      customerId:   customerId,
      customerName: customerName,
      year:         year,
      month:        month,
      deliveries:   deliveryRows.map(Delivery.fromMap).toList(),
      payments:     paymentRows.map(Payment.fromMap).toList(),
    );
  }

  // ── TODAY'S DELIVERIES ───────────────────────────────────────────────────────

  /// Returns all deliveries for today, confirmed or draft.
  /// Used by home screen to show session progress.
  Future<List<Delivery>> getTodayDeliveries() async {
    // TODO(Step 12): expand with session_id filtering
    final db    = await DatabaseProvider.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows  = await db.query(
      'deliveries',
      where: 'date = ?',
      whereArgs: [today],
      orderBy: 'created_at ASC',
    );
    return rows.map(Delivery.fromMap).toList();
  }

  // ── MONTHLY SUMMARY ──────────────────────────────────────────────────────────

  /// Returns the P&L summary for a given month.
  /// Aggregates milk revenue, other income, expenses, and payments.
  Future<MonthlySummary> getMonthlySummary(int year, int month) async {
    // TODO(Step 16): full implementation
    final db        = await DatabaseProvider.database;
    final monthStr  = month.toString().padLeft(2, '0');
    final prefix    = '$year-$monthStr';

    // Milk revenue (confirmed deliveries)
    final delivRows = await db.rawQuery(
      "SELECT COALESCE(SUM(total_value),0) as rev, COALESCE(SUM(liters),0) as lit "
      "FROM deliveries WHERE date LIKE ? AND status='confirmed'",
      ['$prefix%'],
    );
    final revenue = (delivRows.first['rev'] as num).toDouble();
    final liters  = (delivRows.first['lit'] as num).toDouble();

    // Other income
    final incRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) as inc FROM other_income WHERE date LIKE ?',
      ['$prefix%'],
    );
    final otherInc = (incRows.first['inc'] as num).toDouble();

    // Expenses
    final expRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) as exp FROM expenses WHERE date LIKE ?',
      ['$prefix%'],
    );
    final expenses = (expRows.first['exp'] as num).toDouble();

    // Payments collected
    final payRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) as paid FROM payments WHERE date LIKE ?',
      ['$prefix%'],
    );
    final collected = (payRows.first['paid'] as num).toDouble();

    // Active customer count
    final custRows = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM customers WHERE is_active = 1',
    );
    final custCount = (custRows.first['cnt'] as num).toInt();

    return MonthlySummary(
      year:                year,
      month:               month,
      totalMilkRevenue:    revenue,
      totalLiters:         liters,
      otherIncome:         otherInc,
      totalExpenses:       expenses,
      grossProfit:         revenue + otherInc - expenses,
      activeCustomerCount: custCount,
      totalCollected:      collected,
    );
  }
}
