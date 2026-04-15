// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statementRepositoryHash() =>
    r'fdd804e5bca906d24c594579c9be7302d396626e';

/// See also [statementRepository].
@ProviderFor(statementRepository)
final statementRepositoryProvider =
    AutoDisposeProvider<StatementRepository>.internal(
  statementRepository,
  name: r'statementRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statementRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatementRepositoryRef = AutoDisposeProviderRef<StatementRepository>;
String _$todayDeliveriesHash() => r'36f5e7c13cb36a9e8dd27a429ec7c04176affd69';

/// All deliveries recorded today (confirmed + session_draft).
///
/// Used by home screen to show how many customers have been served today.
/// Invalidate after confirming a delivery or saving a session:
/// ```dart
/// ref.invalidate(todayDeliveriesProvider);
/// ```
///
/// Copied from [todayDeliveries].
@ProviderFor(todayDeliveries)
final todayDeliveriesProvider =
    AutoDisposeFutureProvider<List<Delivery>>.internal(
  todayDeliveries,
  name: r'todayDeliveriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayDeliveriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayDeliveriesRef = AutoDisposeFutureProviderRef<List<Delivery>>;
String _$customerStatementHash() => r'3987266a568a6c151e74ddea58bf7f8b60d1b755';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

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
///
/// Copied from [customerStatement].
@ProviderFor(customerStatement)
const customerStatementProvider = CustomerStatementFamily();

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
///
/// Copied from [customerStatement].
class CustomerStatementFamily extends Family<AsyncValue<CustomerStatement>> {
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
  ///
  /// Copied from [customerStatement].
  const CustomerStatementFamily();

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
  ///
  /// Copied from [customerStatement].
  CustomerStatementProvider call(
    String customerId,
    int year,
    int month,
  ) {
    return CustomerStatementProvider(
      customerId,
      year,
      month,
    );
  }

  @override
  CustomerStatementProvider getProviderOverride(
    covariant CustomerStatementProvider provider,
  ) {
    return call(
      provider.customerId,
      provider.year,
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerStatementProvider';
}

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
///
/// Copied from [customerStatement].
class CustomerStatementProvider
    extends AutoDisposeFutureProvider<CustomerStatement> {
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
  ///
  /// Copied from [customerStatement].
  CustomerStatementProvider(
    String customerId,
    int year,
    int month,
  ) : this._internal(
          (ref) => customerStatement(
            ref as CustomerStatementRef,
            customerId,
            year,
            month,
          ),
          from: customerStatementProvider,
          name: r'customerStatementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$customerStatementHash,
          dependencies: CustomerStatementFamily._dependencies,
          allTransitiveDependencies:
              CustomerStatementFamily._allTransitiveDependencies,
          customerId: customerId,
          year: year,
          month: month,
        );

  CustomerStatementProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
    required this.year,
    required this.month,
  }) : super.internal();

  final String customerId;
  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<CustomerStatement> Function(CustomerStatementRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerStatementProvider._internal(
        (ref) => create(ref as CustomerStatementRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CustomerStatement> createElement() {
    return _CustomerStatementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerStatementProvider &&
        other.customerId == customerId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerStatementRef on AutoDisposeFutureProviderRef<CustomerStatement> {
  /// The parameter `customerId` of this provider.
  String get customerId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _CustomerStatementProviderElement
    extends AutoDisposeFutureProviderElement<CustomerStatement>
    with CustomerStatementRef {
  _CustomerStatementProviderElement(super.provider);

  @override
  String get customerId => (origin as CustomerStatementProvider).customerId;
  @override
  int get year => (origin as CustomerStatementProvider).year;
  @override
  int get month => (origin as CustomerStatementProvider).month;
}

String _$monthlySummaryHash() => r'f75f3b82678a4353c60cbdd208bf09089609d3ef';

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
///
/// Copied from [monthlySummary].
@ProviderFor(monthlySummary)
const monthlySummaryProvider = MonthlySummaryFamily();

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
///
/// Copied from [monthlySummary].
class MonthlySummaryFamily extends Family<AsyncValue<MonthlySummary>> {
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
  ///
  /// Copied from [monthlySummary].
  const MonthlySummaryFamily();

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
  ///
  /// Copied from [monthlySummary].
  MonthlySummaryProvider call(
    int year,
    int month,
  ) {
    return MonthlySummaryProvider(
      year,
      month,
    );
  }

  @override
  MonthlySummaryProvider getProviderOverride(
    covariant MonthlySummaryProvider provider,
  ) {
    return call(
      provider.year,
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlySummaryProvider';
}

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
///
/// Copied from [monthlySummary].
class MonthlySummaryProvider extends AutoDisposeFutureProvider<MonthlySummary> {
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
  ///
  /// Copied from [monthlySummary].
  MonthlySummaryProvider(
    int year,
    int month,
  ) : this._internal(
          (ref) => monthlySummary(
            ref as MonthlySummaryRef,
            year,
            month,
          ),
          from: monthlySummaryProvider,
          name: r'monthlySummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlySummaryHash,
          dependencies: MonthlySummaryFamily._dependencies,
          allTransitiveDependencies:
              MonthlySummaryFamily._allTransitiveDependencies,
          year: year,
          month: month,
        );

  MonthlySummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<MonthlySummary> Function(MonthlySummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlySummaryProvider._internal(
        (ref) => create(ref as MonthlySummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MonthlySummary> createElement() {
    return _MonthlySummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySummaryProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlySummaryRef on AutoDisposeFutureProviderRef<MonthlySummary> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _MonthlySummaryProviderElement
    extends AutoDisposeFutureProviderElement<MonthlySummary>
    with MonthlySummaryRef {
  _MonthlySummaryProviderElement(super.provider);

  @override
  int get year => (origin as MonthlySummaryProvider).year;
  @override
  int get month => (origin as MonthlySummaryProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
