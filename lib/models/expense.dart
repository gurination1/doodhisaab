/// Expense model.
///
/// Expenses reduce farm profit in the P&L report.
/// Category must be one of the 6 defined values — validated at the UI layer,
/// not enforced by SQLite (TEXT column with no CHECK constraint in schema).
///
/// Valid categories: Feed | Medicine | Fuel | Electricity | Labor | Other
class Expense {
  final String expenseId;
  final String date;      // ISO-8601 date string 'YYYY-MM-DD'
  final String category;  // Feed | Medicine | Fuel | Electricity | Labor | Other
  final double amount;
  final String? note;
  final String createdAt; // ISO-8601 datetime string

  const Expense({
    required this.expenseId,
    required this.date,
    required this.category,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  static const List<String> validCategories = [
    'Feed',
    'Medicine',
    'Fuel',
    'Electricity',
    'Labor',
    'Other',
  ];

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        expenseId: m['expense_id'] as String,
        date: m['date'] as String,
        category: m['category'] as String,
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'expense_id': expenseId,
        'date': date,
        'category': category,
        'amount': amount,
        'note': note,
        'created_at': createdAt,
      };

  Expense copyWith({
    String? expenseId,
    String? date,
    String? category,
    double? amount,
    String? note,
    String? createdAt,
  }) =>
      Expense(
        expenseId: expenseId ?? this.expenseId,
        date: date ?? this.date,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'Expense($expenseId, $category, ₹$amount)';
}
