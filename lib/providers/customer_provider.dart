import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/customer_repository.dart';
import '../models/customer.dart';

part 'customer_provider.g.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────────────────────────

/// Provides a [CustomerRepository] instance.
///
/// Kept as a provider (not a singleton) so tests can override it with a mock.
@riverpod
CustomerRepository customerRepository(CustomerRepositoryRef ref) =>
    CustomerRepository();

// ── DATA PROVIDERS ────────────────────────────────────────────────────────────

/// All active customers sorted by route_order ASC.
///
/// Invalidate after any add / edit / archive:
/// ```dart
/// ref.invalidate(activeCustomersProvider);
/// ```
@riverpod
Future<List<Customer>> activeCustomers(ActiveCustomersRef ref) =>
    ref.watch(customerRepositoryProvider).getActiveCustomers();

/// Current milk price per liter.
///
/// Returns 0.0 if no price has been set yet (first launch before onboarding).
/// Invalidate after a price change:
/// ```dart
/// ref.invalidate(currentMilkPriceProvider);
/// ```
@riverpod
Future<double> currentMilkPrice(CurrentMilkPriceRef ref) =>
    ref.watch(customerRepositoryProvider).getCurrentPrice();
