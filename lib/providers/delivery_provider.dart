import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/statement_repository.dart';
import '../models/customer_statement.dart';
import '../models/delivery.dart';
import '../models/monthly_summary.dart';

part 'delivery_provider.g.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────────────────────────

@riverpod
StatementRepository statementRepository(StatementRepositoryRef ref) =>
    StatementRepository();

// ── DATA PROVIDERS ────────────────────────────────────────────────────────────

/// All deliveries recorded today (confirmed + session_draft).
///
/// Used by home screen to show how many customers have been served today.
/// Invalidate after confirming a delivery or saving a session:
/// ```dart
/// ref.invalidate(todayDeliveriesProvider);
/// ```
@riverpod
Future<List<Delivery>> todayDeliveries(TodayDeliveriesRef ref) =>
    ref.watch(statementRepositoryProvider).getTodayDeliveries();

/// Monthly statement for a single customer — FAMILY PROVIDER.
///
/// Usage:
/// ```dart
/// final statAsync = ref.watch(customerStatementProvider(customerId, year, month));
/// return statAsync.when(
///   loading: () => const _Skeleton(),
///   error:   (e, _) => Center(child: Text('Error: $e')),
///   data:    (statement) => _StatementView(statement),
/// );
/// ```
///
/// Architecture: uses FutureBuilder / .when() on the main isolate.
/// NEVER move sqflite calls to Isolate.run() — MethodChannel crosses isolate = crash.
@riverpod
Future<CustomerStatement> customerStatement(
  CustomerStatementRef ref,
  String customerId,
  int year,
  int month,
) =>
    ref
        .watch(statementRepositoryProvider)
        .getCustomerStatement(customerId, year, month);

/// Monthly P&L summary — FAMILY PROVIDER.
///
/// Usage:
/// ```dart
/// final summaryAsync = ref.watch(monthlySummaryProvider(year, month));
/// ```
///
/// Invalidate after any delivery, payment, expense, or other-income write:
/// ```dart
/// ref.invalidate(monthlySummaryProvider(year, month));
/// ```
@riverpod
Future<MonthlySummary> monthlySummary(
  MonthlySummaryRef ref,
  int year,
  int month,
) =>
    ref.watch(statementRepositoryProvider).getMonthlySummary(year, month);
