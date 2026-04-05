import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import 'db_provider.dart';
import 'price_repository.dart';

/// Full customer data-access layer.
///
/// Balance update contract — enforced here, never deviate:
///  - [adjustCachedBalance] : O(1) delta, called on every delivery confirm + payment
///  - [repairAllBalances]   : full JOIN, called ONCE at cold start only
///  - No other code path may update cached_balance directly.
///
/// Route order: integers starting at 0, contiguous. [addCustomer] appends to
/// the end. Reordering UI (future step) uses [setRouteOrder].
class CustomerRepository {
  CustomerRepository();
  static final CustomerRepository instance = CustomerRepository();

  final _uuid = const Uuid();
  final _priceRepo = PriceRepository();

  // ── READ ──────────────────────────────────────────────────────────────────

  /// Active customers sorted by route_order ASC.
  /// Uses idx_cust_active_route — fast even at 500+ customers.
  Future<List<Customer>> getActiveCustomers() async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'customers',
      where: 'is_active = 1',
      orderBy: 'route_order ASC',
    );
    return rows.map(Customer.fromMap).toList();
  }

  /// All customers including archived — for admin/export views.
  Future<List<Customer>> getAllCustomers() async {
    final db = await DatabaseProvider.database;
    final rows = await db.query('customers', orderBy: 'route_order ASC');
    return rows.map(Customer.fromMap).toList();
  }

  /// Single customer lookup. Returns null if not found.
  Future<Customer?> getCustomerById(String customerId) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      'customers',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      limit: 1,
    );
    return rows.isEmpty ? null : Customer.fromMap(rows.first);
  }

  /// Current milk price per liter — delegates to PriceRepository.
  /// Returns 0.0 if no price has been set yet (pre-onboarding).
  Future<double> getCurrentPrice() => _priceRepo.getCurrentPrice();

  /// True if the customer has an outstanding balance AND their last payment
  /// (or first delivery, if no payments) is outside their payment cycle window.
  Future<bool> isCustomerOverdue(Customer c) async {
    if (c.cachedBalance <= 0) return false;

    final cycleDays = switch (c.paymentCycle) {
      'Weekly'   => 7,
      'BiWeekly' => 14,
      'Monthly'  => 30,
      'Custom'   => c.paymentCycleDays ?? 30,
      _          => 30,
    };

    final db = await DatabaseProvider.database;

    // Most recent payment date for this customer
    final payRows = await db.query(
      'payments',
      columns: ['date'],
      where: 'customer_id = ?',
      whereArgs: [c.customerId],
      orderBy: 'date DESC',
      limit: 1,
    );

    String? lastActivityDate;

    if (payRows.isNotEmpty) {
      lastActivityDate = payRows.first['date'] as String;
    } else {
      // No payments — fall back to first confirmed delivery date
      final delRows = await db.query(
        'deliveries',
        columns: ['date'],
        where: "customer_id = ? AND status = 'confirmed'",
        whereArgs: [c.customerId],
        orderBy: 'date ASC',
        limit: 1,
      );
      if (delRows.isNotEmpty) {
        lastActivityDate = delRows.first['date'] as String;
      }
    }

    if (lastActivityDate == null) return false;
    final daysAgo = DateTime.now().difference(DateTime.parse(lastActivityDate)).inDays;
    return daysAgo > cycleDays;
  }

  // ── WRITE ─────────────────────────────────────────────────────────────────

  /// Adds a new customer, appending to the end of the active delivery route.
  ///
  /// Generates a UUID and assigns the next route_order automatically.
  /// [cachedBalance] is always 0.0 on creation.
  Future<Customer> addCustomer({
    required String name,
    String? phone,
    String? address,
    double defaultLiters = 2.0,
    String paymentCycle = 'Monthly',
    int? paymentCycleDays,
    double? priceOverride,
    String? priceOverrideReason,
  }) async {
    final db = await DatabaseProvider.database;

    // Assign route_order = current max + 1 (append to end)
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(route_order), -1) as m FROM customers WHERE is_active = 1',
    );
    final maxOrder = (maxRow.first['m'] as num).toInt();

    final customer = Customer(
      customerId:          _uuid.v4(),
      name:                name,
      phone:               phone,
      address:             address,
      defaultLiters:       defaultLiters,
      paymentCycle:        paymentCycle,
      paymentCycleDays:    paymentCycleDays,
      priceOverride:       priceOverride,
      priceOverrideReason: priceOverrideReason,
      routeOrder:          maxOrder + 1,
      isActive:            true,
      archivedAt:          null,
      cachedBalance:       0.0,
      createdAt:           DateTime.now().toIso8601String(),
    );

    await db.insert('customers', customer.toMap());
    return customer;
  }

  /// Updates editable profile fields.
  ///
  /// Does NOT touch [cachedBalance], [routeOrder], [isActive],
  /// [archivedAt], or [createdAt] — those have dedicated methods.
  Future<void> updateCustomer(Customer customer) async {
    final db = await DatabaseProvider.database;
    await db.update(
      'customers',
      {
        'name':                  customer.name,
        'phone':                 customer.phone,
        'address':               customer.address,
        'default_liters':        customer.defaultLiters,
        'payment_cycle':         customer.paymentCycle,
        'payment_cycle_days':    customer.paymentCycleDays,
        'price_override':        customer.priceOverride,
        'price_override_reason': customer.priceOverrideReason,
      },
      where: 'customer_id = ?',
      whereArgs: [customer.customerId],
    );
  }

  /// Soft-deletes a customer. Historical data is retained.
  /// Archived customers are excluded from delivery sessions and the active list.
  Future<void> archiveCustomer(String customerId) async {
    final db = await DatabaseProvider.database;
    await db.update(
      'customers',
      {
        'is_active':   0,
        'archived_at': DateTime.now().toIso8601String(),
      },
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }

  /// Restores an archived customer. Appends to end of active route.
  Future<void> reactivateCustomer(String customerId) async {
    final db = await DatabaseProvider.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(route_order), -1) as m FROM customers WHERE is_active = 1',
    );
    final maxOrder = (maxRow.first['m'] as num).toInt();
    await db.update(
      'customers',
      {
        'is_active':   1,
        'archived_at': null,
        'route_order': maxOrder + 1,
      },
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }

  /// Sets a customer's explicit position in the delivery route.
  /// Used by drag-to-reorder UI (future step).
  Future<void> setRouteOrder(String customerId, int order) async {
    final db = await DatabaseProvider.database;
    await db.update(
      'customers',
      {'route_order': order},
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }

  // ── BALANCE ───────────────────────────────────────────────────────────────

  /// O(1) delta update — the ONLY correct way to change cached_balance per-op.
  ///
  ///  delivery confirmed     → adjustCachedBalance(id, +totalValue)
  ///  delivery re-confirmed  → adjustCachedBalance(id, newValue - oldValue)
  ///  payment saved          → adjustCachedBalance(id, -amount)
  ///
  /// NEVER replace this with a full SUM query per interaction.
  Future<void> adjustCachedBalance(String customerId, double delta) async {
    final db = await DatabaseProvider.database;
    await db.rawUpdate(
      'UPDATE customers SET cached_balance = cached_balance + ? WHERE customer_id = ?',
      [delta, customerId],
    );
  }

  /// Full balance repair — called ONCE at app cold start only.
  ///
  /// Recomputes every customer's cached_balance from confirmed deliveries
  /// and all payments via a correlated subquery. Fixes any drift from crashes.
  /// Runs <200ms with idx_del_cust_date + idx_pay_cust_date indices.
  Future<void> repairAllBalances() async {
    final db = await DatabaseProvider.database;
    await db.rawUpdate('''
      UPDATE customers SET cached_balance = (
        SELECT COALESCE(SUM(d.total_value), 0) FROM deliveries d
        WHERE d.customer_id = customers.customer_id AND d.status = 'confirmed'
      ) - (
        SELECT COALESCE(SUM(p.amount), 0) FROM payments p
        WHERE p.customer_id = customers.customer_id
      )
    ''');
  }
}
