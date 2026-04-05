/// Customer model.
///
/// Key rules:
///  - [isActive] stored as INTEGER 0/1 in SQLite — fromMap casts (int)==1,
///    toMap converts bool→int. Never store 'true'/'false' strings.
///  - [cachedBalance] is maintained by adjustCachedBalance() delta updates.
///    Never run a full SUM query per customer on-demand — use this field.
///  - Nullable fields match nullable columns in the schema exactly.
///    A field that is NOT NULL in SQLite must NOT be nullable here.
class Customer {
  final String customerId;
  final String name;
  final String? phone;
  final String? address;
  final double defaultLiters;
  final String paymentCycle;       // 'Monthly' | 'Weekly' | 'Custom'
  final int? paymentCycleDays;     // only set when paymentCycle == 'Custom'
  final double? priceOverride;     // null = use global price
  final String? priceOverrideReason;
  final int routeOrder;
  final bool isActive;
  final String? archivedAt;        // ISO-8601 date string, null if active
  final double cachedBalance;      // positive = owes money, negative = credit
  final String createdAt;          // ISO-8601 datetime string

  const Customer({
    required this.customerId,
    required this.name,
    this.phone,
    this.address,
    required this.defaultLiters,
    required this.paymentCycle,
    this.paymentCycleDays,
    this.priceOverride,
    this.priceOverrideReason,
    required this.routeOrder,
    required this.isActive,
    this.archivedAt,
    required this.cachedBalance,
    required this.createdAt,
  });

  /// Creates a Customer from a SQLite row map.
  ///
  /// Key strings MUST match column names exactly (snake_case).
  /// Nullable columns cast as `Type?`. NOT NULL columns cast as `Type`.
  /// Boolean column [isActive] is stored as INTEGER 0/1 — compare == 1.
  factory Customer.fromMap(Map<String, dynamic> m) => Customer(
        customerId: m['customer_id'] as String,
        name: m['name'] as String,
        phone: m['phone'] as String?,
        address: m['address'] as String?,
        defaultLiters: (m['default_liters'] as num).toDouble(),
        paymentCycle: m['payment_cycle'] as String,
        paymentCycleDays: m['payment_cycle_days'] as int?,
        priceOverride: m['price_override'] != null
            ? (m['price_override'] as num).toDouble()
            : null,
        priceOverrideReason: m['price_override_reason'] as String?,
        routeOrder: m['route_order'] as int,
        isActive: (m['is_active'] as int) == 1,
        archivedAt: m['archived_at'] as String?,
        cachedBalance: (m['cached_balance'] as num).toDouble(),
        createdAt: m['created_at'] as String,
      );

  /// Converts to a map for SQLite insert/update.
  ///
  /// [isActive] converted back to INTEGER (1/0).
  /// Nullable fields pass null through — SQLite stores as NULL.
  Map<String, dynamic> toMap() => {
        'customer_id': customerId,
        'name': name,
        'phone': phone,
        'address': address,
        'default_liters': defaultLiters,
        'payment_cycle': paymentCycle,
        'payment_cycle_days': paymentCycleDays,
        'price_override': priceOverride,
        'price_override_reason': priceOverrideReason,
        'route_order': routeOrder,
        'is_active': isActive ? 1 : 0,
        'archived_at': archivedAt,
        'cached_balance': cachedBalance,
        'created_at': createdAt,
      };

  /// Returns a copy with specific fields replaced.
  Customer copyWith({
    String? customerId,
    String? name,
    String? phone,
    String? address,
    double? defaultLiters,
    String? paymentCycle,
    int? paymentCycleDays,
    double? priceOverride,
    String? priceOverrideReason,
    int? routeOrder,
    bool? isActive,
    String? archivedAt,
    double? cachedBalance,
    String? createdAt,
  }) =>
      Customer(
        customerId: customerId ?? this.customerId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        defaultLiters: defaultLiters ?? this.defaultLiters,
        paymentCycle: paymentCycle ?? this.paymentCycle,
        paymentCycleDays: paymentCycleDays ?? this.paymentCycleDays,
        priceOverride: priceOverride ?? this.priceOverride,
        priceOverrideReason: priceOverrideReason ?? this.priceOverrideReason,
        routeOrder: routeOrder ?? this.routeOrder,
        isActive: isActive ?? this.isActive,
        archivedAt: archivedAt ?? this.archivedAt,
        cachedBalance: cachedBalance ?? this.cachedBalance,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'Customer($customerId, $name, balance=$cachedBalance)';
}
