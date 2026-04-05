/// PriceHistory model.
///
/// Every milk price change is recorded here with its effective date.
/// Used to calculate the correct price for historical deliveries when a customer
/// disputes a past record — look up the price in effect on that date.
///
/// The current price is the row with the most recent [effectiveFrom] date.
/// Query: SELECT * FROM price_history ORDER BY effective_from DESC LIMIT 1
class PriceHistory {
  final String priceId;
  final double pricePerLiter;
  final String effectiveFrom; // ISO-8601 date string 'YYYY-MM-DD'
  final String? note;

  const PriceHistory({
    required this.priceId,
    required this.pricePerLiter,
    required this.effectiveFrom,
    this.note,
  });

  factory PriceHistory.fromMap(Map<String, dynamic> m) => PriceHistory(
        priceId: m['price_id'] as String,
        pricePerLiter: (m['price_per_liter'] as num).toDouble(),
        effectiveFrom: m['effective_from'] as String,
        note: m['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'price_id': priceId,
        'price_per_liter': pricePerLiter,
        'effective_from': effectiveFrom,
        'note': note,
      };

  PriceHistory copyWith({
    String? priceId,
    double? pricePerLiter,
    String? effectiveFrom,
    String? note,
  }) =>
      PriceHistory(
        priceId: priceId ?? this.priceId,
        pricePerLiter: pricePerLiter ?? this.pricePerLiter,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        note: note ?? this.note,
      );

  @override
  String toString() =>
      'PriceHistory($priceId, ₹$pricePerLiter from $effectiveFrom)';
}
