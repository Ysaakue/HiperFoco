// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsSummaryHash() => r'd40008880615f16da70f933170e2973a658fd086';

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

/// Combines the compacted history (`archivedBetweenProvider`) with today's
/// still-hot intervals (`intervalsForDayProvider`), re-running whenever
/// either source changes — mirrors the same "combine multiple stream
/// providers via async*" pattern already used by `occurrencesForRange` for
/// the calendar.
///
/// Copied from [statisticsSummary].
@ProviderFor(statisticsSummary)
const statisticsSummaryProvider = StatisticsSummaryFamily();

/// Combines the compacted history (`archivedBetweenProvider`) with today's
/// still-hot intervals (`intervalsForDayProvider`), re-running whenever
/// either source changes — mirrors the same "combine multiple stream
/// providers via async*" pattern already used by `occurrencesForRange` for
/// the calendar.
///
/// Copied from [statisticsSummary].
class StatisticsSummaryFamily extends Family<AsyncValue<StatisticsSummary>> {
  /// Combines the compacted history (`archivedBetweenProvider`) with today's
  /// still-hot intervals (`intervalsForDayProvider`), re-running whenever
  /// either source changes — mirrors the same "combine multiple stream
  /// providers via async*" pattern already used by `occurrencesForRange` for
  /// the calendar.
  ///
  /// Copied from [statisticsSummary].
  const StatisticsSummaryFamily();

  /// Combines the compacted history (`archivedBetweenProvider`) with today's
  /// still-hot intervals (`intervalsForDayProvider`), re-running whenever
  /// either source changes — mirrors the same "combine multiple stream
  /// providers via async*" pattern already used by `occurrencesForRange` for
  /// the calendar.
  ///
  /// Copied from [statisticsSummary].
  StatisticsSummaryProvider call(
    StatisticsPeriod period,
    DateTime referenceDate,
  ) {
    return StatisticsSummaryProvider(period, referenceDate);
  }

  @override
  StatisticsSummaryProvider getProviderOverride(
    covariant StatisticsSummaryProvider provider,
  ) {
    return call(provider.period, provider.referenceDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'statisticsSummaryProvider';
}

/// Combines the compacted history (`archivedBetweenProvider`) with today's
/// still-hot intervals (`intervalsForDayProvider`), re-running whenever
/// either source changes — mirrors the same "combine multiple stream
/// providers via async*" pattern already used by `occurrencesForRange` for
/// the calendar.
///
/// Copied from [statisticsSummary].
class StatisticsSummaryProvider
    extends AutoDisposeStreamProvider<StatisticsSummary> {
  /// Combines the compacted history (`archivedBetweenProvider`) with today's
  /// still-hot intervals (`intervalsForDayProvider`), re-running whenever
  /// either source changes — mirrors the same "combine multiple stream
  /// providers via async*" pattern already used by `occurrencesForRange` for
  /// the calendar.
  ///
  /// Copied from [statisticsSummary].
  StatisticsSummaryProvider(StatisticsPeriod period, DateTime referenceDate)
    : this._internal(
        (ref) => statisticsSummary(
          ref as StatisticsSummaryRef,
          period,
          referenceDate,
        ),
        from: statisticsSummaryProvider,
        name: r'statisticsSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$statisticsSummaryHash,
        dependencies: StatisticsSummaryFamily._dependencies,
        allTransitiveDependencies:
            StatisticsSummaryFamily._allTransitiveDependencies,
        period: period,
        referenceDate: referenceDate,
      );

  StatisticsSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
    required this.referenceDate,
  }) : super.internal();

  final StatisticsPeriod period;
  final DateTime referenceDate;

  @override
  Override overrideWith(
    Stream<StatisticsSummary> Function(StatisticsSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StatisticsSummaryProvider._internal(
        (ref) => create(ref as StatisticsSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
        referenceDate: referenceDate,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<StatisticsSummary> createElement() {
    return _StatisticsSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StatisticsSummaryProvider &&
        other.period == period &&
        other.referenceDate == referenceDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);
    hash = _SystemHash.combine(hash, referenceDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StatisticsSummaryRef on AutoDisposeStreamProviderRef<StatisticsSummary> {
  /// The parameter `period` of this provider.
  StatisticsPeriod get period;

  /// The parameter `referenceDate` of this provider.
  DateTime get referenceDate;
}

class _StatisticsSummaryProviderElement
    extends AutoDisposeStreamProviderElement<StatisticsSummary>
    with StatisticsSummaryRef {
  _StatisticsSummaryProviderElement(super.provider);

  @override
  StatisticsPeriod get period => (origin as StatisticsSummaryProvider).period;
  @override
  DateTime get referenceDate =>
      (origin as StatisticsSummaryProvider).referenceDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
