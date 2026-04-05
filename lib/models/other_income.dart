/// OtherIncome model.
///
/// Non-milk farm income — increases profit in the P&L report.
/// IMPORTANT: This table is queried by the CSV export service (Step 20).
/// The "OTHER INCOME" section in the CSV depends on this model being correct.
/// Do not rename fields without updating csv_export_service.dart.
///
/// Valid categories: Calf Sale | Ghee Sale | Manure Sale | Other
class OtherIncome {
  final String incomeId;
  final String date;      // ISO-8601 date string 'YYYY-MM-DD'
  final String category;  // Calf Sale | Ghee Sale | Manure Sale | Other
  final double amount;
  final String? note;
  final String createdAt; // ISO-8601 datetime string

  const OtherIncome({
    required this.incomeId,
    required this.date,
    required this.category,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  static const List<String> validCategories = [
    'Calf Sale',
    'Ghee Sale',
    'Manure Sale',
    'Other',
  ];

  factory OtherIncome.fromMap(Map<String, dynamic> m) => OtherIncome(
        incomeId: m['income_id'] as String,
        date: m['date'] as String,
        category: m['category'] as String,
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'income_id': incomeId,
        'date': date,
        'category': category,
        'amount': amount,
        'note': note,
        'created_at': createdAt,
      };

  OtherIncome copyWith({
    String? incomeId,
    String? date,
    String? category,
    double? amount,
    String? note,
    String? createdAt,
  }) =>
      OtherIncome(
        incomeId: incomeId ?? this.incomeId,
        date: date ?? this.date,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'OtherIncome($incomeId, $category, ₹$amount)';
}
