/// View-model for the monthly P&L report.
///
/// Assembled by StatementRepository from all confirmed data for a given month.
/// Not persisted — computed on demand. Used by [monthlySummaryProvider].
///
/// Architecture: must run on the main isolate via FutureBuilder.
/// Never pass this computation to Isolate.run() — sqflite crashes across isolates.
class MonthlySummary {
  final int year;
  final int month;

  // Revenue
  final double totalMilkRevenue;   // SUM(deliveries.total_value) WHERE confirmed
  final double totalLiters;        // SUM(deliveries.liters) WHERE confirmed
  final double otherIncome;        // SUM(other_income.amount)

  // Expenses
  final double totalExpenses;      // SUM(expenses.amount)

  // Profit
  final double grossProfit;        // totalMilkRevenue + otherIncome - totalExpenses

  // Customer stats
  final int activeCustomerCount;
  final double totalCollected;     // SUM(payments.amount) this month

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalMilkRevenue,
    required this.totalLiters,
    required this.otherIncome,
    required this.totalExpenses,
    required this.grossProfit,
    required this.activeCustomerCount,
    required this.totalCollected,
  });

  /// Empty summary — used as loading placeholder or when no data exists.
  factory MonthlySummary.empty(int year, int month) => MonthlySummary(
        year: year,
        month: month,
        totalMilkRevenue: 0,
        totalLiters: 0,
        otherIncome: 0,
        totalExpenses: 0,
        grossProfit: 0,
        activeCustomerCount: 0,
        totalCollected: 0,
      );

  bool get hasData =>
      totalLiters > 0 ||
      totalExpenses > 0 ||
      otherIncome > 0 ||
      totalCollected > 0 ||
      totalMilkRevenue > 0;

  @override
  String toString() =>
      'MonthlySummary($year-$month, revenue=$totalMilkRevenue, profit=$grossProfit)';
}
