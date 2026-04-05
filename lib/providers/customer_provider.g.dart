// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerRepositoryHash() =>
    r'3560db8bda8dff691d3f93da83ebd15ee79285da';

/// Provides a [CustomerRepository] instance.
///
/// Kept as a provider (not a singleton) so tests can override it with a mock.
///
/// Copied from [customerRepository].
@ProviderFor(customerRepository)
final customerRepositoryProvider =
    AutoDisposeProvider<CustomerRepository>.internal(
  customerRepository,
  name: r'customerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerRepositoryRef = AutoDisposeProviderRef<CustomerRepository>;
String _$activeCustomersHash() => r'92cdb9742a109be0d8f93479b2909b412e61e447';

/// All active customers sorted by route_order ASC.
///
/// Invalidate after any add / edit / archive:
/// ```dart
/// ref.invalidate(activeCustomersProvider);
/// ```
///
/// Copied from [activeCustomers].
@ProviderFor(activeCustomers)
final activeCustomersProvider =
    AutoDisposeFutureProvider<List<Customer>>.internal(
  activeCustomers,
  name: r'activeCustomersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCustomersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCustomersRef = AutoDisposeFutureProviderRef<List<Customer>>;
String _$currentMilkPriceHash() => r'6f17883901765f5565e5cf71caa868067c36de44';

/// Current milk price per liter.
///
/// Returns 0.0 if no price has been set yet (first launch before onboarding).
/// Invalidate after a price change:
/// ```dart
/// ref.invalidate(currentMilkPriceProvider);
/// ```
///
/// Copied from [currentMilkPrice].
@ProviderFor(currentMilkPrice)
final currentMilkPriceProvider = AutoDisposeFutureProvider<double>.internal(
  currentMilkPrice,
  name: r'currentMilkPriceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMilkPriceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMilkPriceRef = AutoDisposeFutureProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
