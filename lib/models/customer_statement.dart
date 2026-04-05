import 'delivery.dart';
import 'payment.dart';

/// View-model for the Customer Statement report.
///
/// Assembled by StatementRepository from raw deliveries and payments.
/// Not persisted to SQLite — computed on demand from confirmed records.
///
/// Architecture note: StatementRepository must run on the MAIN ISOLATE via
/// FutureBuilder. Never use Isolate.run() for this — sqflite's MethodChannel
/// is bound to the main isolate and will throw across isolate boundaries.
///
/// [balance] = totalValue - totalPaid
///   positive → customer owes money
///   negative → customer has a credit (overpaid)
///   zero     → settled
class CustomerStatement {
  final String customerId;
  final String customerName;
  final int year;
  final int month;
  final List<Delivery> deliveries;  // confirmed only, this customer, this month
  final List<Payment> payments;     // this customer, this month
  final double totalLiters;
  final double totalValue;          // sum of delivery.totalValue
  final double totalPaid;           // sum of payment.amount
  final double balance;             // totalValue - totalPaid

  const CustomerStatement({
    required this.customerId,
    required this.customerName,
    required this.year,
    required this.month,
    required this.deliveries,
    required this.payments,
    required this.totalLiters,
    required this.totalValue,
    required this.totalPaid,
    required this.balance,
  });

  /// Convenience constructor — computes totals from the list contents.
  factory CustomerStatement.fromLists({
    required String customerId,
    required String customerName,
    required int year,
    required int month,
    required List<Delivery> deliveries,
    required List<Payment> payments,
  }) {
    final totalLiters = deliveries.fold(0.0, (sum, d) => sum + d.liters);
    final totalValue  = deliveries.fold(0.0, (sum, d) => sum + d.totalValue);
    final totalPaid   = payments.fold(0.0, (sum, p) => sum + p.amount);
    return CustomerStatement(
      customerId:   customerId,
      customerName: customerName,
      year:         year,
      month:        month,
      deliveries:   deliveries,
      payments:     payments,
      totalLiters:  totalLiters,
      totalValue:   totalValue,
      totalPaid:    totalPaid,
      balance:      totalValue - totalPaid,
    );
  }

  bool get isSettled  => balance.abs() < 0.01;
  bool get isOverpaid => balance < -0.01;
  bool get hasBalance => balance > 0.01;

  @override
  String toString() =>
      'CustomerStatement($customerId, $year-$month, '
      'liters=$totalLiters, value=$totalValue, paid=$totalPaid, balance=$balance)';
}
