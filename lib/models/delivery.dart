/// Delivery model.
///
/// Key rules:
///  - [status] drives the write-on-confirm architecture:
///      'session_draft' — written immediately on each customer confirm
///      'confirmed'     — promoted by SAVE ALL (single batch UPDATE)
///      'abandoned'     — set if session is discarded by the user
///  - [sessionId] links all deliveries from one entry session.
///    Used by crash recovery to detect incomplete sessions on next launch.
///  - All num fields use .toDouble() — SQLite REAL may come back as int.
///  - [note] and [sessionId] are nullable — match schema exactly.
class Delivery {
  final String deliveryId;
  final String customerId;
  final String date;             // ISO-8601 date string 'YYYY-MM-DD'
  final double liters;
  final double pricePerLiter;
  final double totalValue;       // liters × pricePerLiter (stored, not computed)
  final String? note;
  final String status;           // 'session_draft' | 'confirmed' | 'abandoned'
  final String? sessionId;       // UUID shared by all deliveries in one session
  final String createdByDevice;  // device_id from app_settings
  final String syncStatus;       // 'local' (MVP only — future cloud sync field)
  final String createdAt;        // ISO-8601 datetime string

  const Delivery({
    required this.deliveryId,
    required this.customerId,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.totalValue,
    this.note,
    required this.status,
    this.sessionId,
    required this.createdByDevice,
    required this.syncStatus,
    required this.createdAt,
  });

  factory Delivery.fromMap(Map<String, dynamic> m) => Delivery(
        deliveryId: m['delivery_id'] as String,
        customerId: m['customer_id'] as String,
        date: m['date'] as String,
        liters: (m['liters'] as num).toDouble(),
        pricePerLiter: (m['price_per_liter'] as num).toDouble(),
        totalValue: (m['total_value'] as num).toDouble(),
        note: m['note'] as String?,
        status: m['status'] as String,
        sessionId: m['session_id'] as String?,
        createdByDevice: m['created_by_device'] as String,
        syncStatus: m['sync_status'] as String,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'delivery_id': deliveryId,
        'customer_id': customerId,
        'date': date,
        'liters': liters,
        'price_per_liter': pricePerLiter,
        'total_value': totalValue,
        'note': note,
        'status': status,
        'session_id': sessionId,
        'created_by_device': createdByDevice,
        'sync_status': syncStatus,
        'created_at': createdAt,
      };

  bool get isDraft => status == 'session_draft';
  bool get isConfirmed => status == 'confirmed';

  Delivery copyWith({
    String? deliveryId,
    String? customerId,
    String? date,
    double? liters,
    double? pricePerLiter,
    double? totalValue,
    String? note,
    String? status,
    String? sessionId,
    String? createdByDevice,
    String? syncStatus,
    String? createdAt,
  }) =>
      Delivery(
        deliveryId: deliveryId ?? this.deliveryId,
        customerId: customerId ?? this.customerId,
        date: date ?? this.date,
        liters: liters ?? this.liters,
        pricePerLiter: pricePerLiter ?? this.pricePerLiter,
        totalValue: totalValue ?? this.totalValue,
        note: note ?? this.note,
        status: status ?? this.status,
        sessionId: sessionId ?? this.sessionId,
        createdByDevice: createdByDevice ?? this.createdByDevice,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() =>
      'Delivery($deliveryId, cust=$customerId, ${liters}L, status=$status)';
}
