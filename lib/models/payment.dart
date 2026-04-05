/// Payment model.
///
/// A payment recorded against a customer reduces their [cachedBalance].
/// The balance adjustment is done via adjustCachedBalance(id, -amount)
/// immediately when the payment is saved — never deferred.
class Payment {
  final String paymentId;
  final String customerId;
  final String date;             // ISO-8601 date string 'YYYY-MM-DD'
  final double amount;
  final String? note;
  final String createdByDevice;  // device_id from app_settings
  final String syncStatus;       // 'local' (MVP only)
  final String createdAt;        // ISO-8601 datetime string

  const Payment({
    required this.paymentId,
    required this.customerId,
    required this.date,
    required this.amount,
    this.note,
    required this.createdByDevice,
    required this.syncStatus,
    required this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> m) => Payment(
        paymentId: m['payment_id'] as String,
        customerId: m['customer_id'] as String,
        date: m['date'] as String,
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String?,
        createdByDevice: m['created_by_device'] as String,
        syncStatus: m['sync_status'] as String,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'payment_id': paymentId,
        'customer_id': customerId,
        'date': date,
        'amount': amount,
        'note': note,
        'created_by_device': createdByDevice,
        'sync_status': syncStatus,
        'created_at': createdAt,
      };

  Payment copyWith({
    String? paymentId,
    String? customerId,
    String? date,
    double? amount,
    String? note,
    String? createdByDevice,
    String? syncStatus,
    String? createdAt,
  }) =>
      Payment(
        paymentId: paymentId ?? this.paymentId,
        customerId: customerId ?? this.customerId,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        createdByDevice: createdByDevice ?? this.createdByDevice,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'Payment($paymentId, cust=$customerId, ₹$amount)';
}
