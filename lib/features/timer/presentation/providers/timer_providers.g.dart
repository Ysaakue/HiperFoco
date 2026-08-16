// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerRepositoryHash() => r'b94368fde5513978af15e0130cf77a5474cfbefe';

/// See also [timerRepository].
@ProviderFor(timerRepository)
final timerRepositoryProvider = Provider<TimerRepository>.internal(
  timerRepository,
  name: r'timerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerRepositoryRef = ProviderRef<TimerRepository>;
String _$startTimerUseCaseHash() => r'adfc91f9648e944738a6c222310312a45e727a8c';

/// See also [startTimerUseCase].
@ProviderFor(startTimerUseCase)
final startTimerUseCaseProvider = AutoDisposeProvider<StartTimer>.internal(
  startTimerUseCase,
  name: r'startTimerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$startTimerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StartTimerUseCaseRef = AutoDisposeProviderRef<StartTimer>;
String _$pauseTimerUseCaseHash() => r'91ba24c0112372731e23bb5803239694e9be7f99';

/// See also [pauseTimerUseCase].
@ProviderFor(pauseTimerUseCase)
final pauseTimerUseCaseProvider = AutoDisposeProvider<PauseTimer>.internal(
  pauseTimerUseCase,
  name: r'pauseTimerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pauseTimerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PauseTimerUseCaseRef = AutoDisposeProviderRef<PauseTimer>;
String _$resumeTimerUseCaseHash() =>
    r'0ac235e44574c9b9e1278ca064319d4e6a91f735';

/// See also [resumeTimerUseCase].
@ProviderFor(resumeTimerUseCase)
final resumeTimerUseCaseProvider = AutoDisposeProvider<ResumeTimer>.internal(
  resumeTimerUseCase,
  name: r'resumeTimerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resumeTimerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResumeTimerUseCaseRef = AutoDisposeProviderRef<ResumeTimer>;
String _$stopTimerUseCaseHash() => r'a30cf6d621a9c880173d037f58a54531bb9acbe9';

/// See also [stopTimerUseCase].
@ProviderFor(stopTimerUseCase)
final stopTimerUseCaseProvider = AutoDisposeProvider<StopTimer>.internal(
  stopTimerUseCase,
  name: r'stopTimerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stopTimerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StopTimerUseCaseRef = AutoDisposeProviderRef<StopTimer>;
String _$activeTimerSessionHash() =>
    r'd1c0ab229cb83b597b0d32d38280ca0131650ee6';

/// See also [activeTimerSession].
@ProviderFor(activeTimerSession)
final activeTimerSessionProvider = StreamProvider<TimerSession?>.internal(
  activeTimerSession,
  name: r'activeTimerSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTimerSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTimerSessionRef = StreamProviderRef<TimerSession?>;
String _$todayCategoryDurationSecondsHash() =>
    r'a37bc97db7ad274193552de38dfb9d50944e2f3d';

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

/// See also [todayCategoryDurationSeconds].
@ProviderFor(todayCategoryDurationSeconds)
const todayCategoryDurationSecondsProvider =
    TodayCategoryDurationSecondsFamily();

/// See also [todayCategoryDurationSeconds].
class TodayCategoryDurationSecondsFamily extends Family<AsyncValue<int>> {
  /// See also [todayCategoryDurationSeconds].
  const TodayCategoryDurationSecondsFamily();

  /// See also [todayCategoryDurationSeconds].
  TodayCategoryDurationSecondsProvider call(int categoryId) {
    return TodayCategoryDurationSecondsProvider(categoryId);
  }

  @override
  TodayCategoryDurationSecondsProvider getProviderOverride(
    covariant TodayCategoryDurationSecondsProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'todayCategoryDurationSecondsProvider';
}

/// See also [todayCategoryDurationSeconds].
class TodayCategoryDurationSecondsProvider
    extends AutoDisposeStreamProvider<int> {
  /// See also [todayCategoryDurationSeconds].
  TodayCategoryDurationSecondsProvider(int categoryId)
    : this._internal(
        (ref) => todayCategoryDurationSeconds(
          ref as TodayCategoryDurationSecondsRef,
          categoryId,
        ),
        from: todayCategoryDurationSecondsProvider,
        name: r'todayCategoryDurationSecondsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todayCategoryDurationSecondsHash,
        dependencies: TodayCategoryDurationSecondsFamily._dependencies,
        allTransitiveDependencies:
            TodayCategoryDurationSecondsFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  TodayCategoryDurationSecondsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int categoryId;

  @override
  Override overrideWith(
    Stream<int> Function(TodayCategoryDurationSecondsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodayCategoryDurationSecondsProvider._internal(
        (ref) => create(ref as TodayCategoryDurationSecondsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _TodayCategoryDurationSecondsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayCategoryDurationSecondsProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodayCategoryDurationSecondsRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _TodayCategoryDurationSecondsProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with TodayCategoryDurationSecondsRef {
  _TodayCategoryDurationSecondsProviderElement(super.provider);

  @override
  int get categoryId =>
      (origin as TodayCategoryDurationSecondsProvider).categoryId;
}

String _$todayTotalDurationSecondsHash() =>
    r'613599ce39bdecc164ccc4e83738804d7b33f0a5';

/// See also [todayTotalDurationSeconds].
@ProviderFor(todayTotalDurationSeconds)
final todayTotalDurationSecondsProvider =
    AutoDisposeStreamProvider<int>.internal(
      todayTotalDurationSeconds,
      name: r'todayTotalDurationSecondsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayTotalDurationSecondsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTotalDurationSecondsRef = AutoDisposeStreamProviderRef<int>;
String _$intervalsForDayHash() => r'ecaab491181b752a72179c95d93aa496bcb4c5d0';

/// See also [intervalsForDay].
@ProviderFor(intervalsForDay)
const intervalsForDayProvider = IntervalsForDayFamily();

/// See also [intervalsForDay].
class IntervalsForDayFamily extends Family<AsyncValue<List<TimerInterval>>> {
  /// See also [intervalsForDay].
  const IntervalsForDayFamily();

  /// See also [intervalsForDay].
  IntervalsForDayProvider call(DateTime day) {
    return IntervalsForDayProvider(day);
  }

  @override
  IntervalsForDayProvider getProviderOverride(
    covariant IntervalsForDayProvider provider,
  ) {
    return call(provider.day);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'intervalsForDayProvider';
}

/// See also [intervalsForDay].
class IntervalsForDayProvider
    extends AutoDisposeStreamProvider<List<TimerInterval>> {
  /// See also [intervalsForDay].
  IntervalsForDayProvider(DateTime day)
    : this._internal(
        (ref) => intervalsForDay(ref as IntervalsForDayRef, day),
        from: intervalsForDayProvider,
        name: r'intervalsForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$intervalsForDayHash,
        dependencies: IntervalsForDayFamily._dependencies,
        allTransitiveDependencies:
            IntervalsForDayFamily._allTransitiveDependencies,
        day: day,
      );

  IntervalsForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
  }) : super.internal();

  final DateTime day;

  @override
  Override overrideWith(
    Stream<List<TimerInterval>> Function(IntervalsForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IntervalsForDayProvider._internal(
        (ref) => create(ref as IntervalsForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimerInterval>> createElement() {
    return _IntervalsForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IntervalsForDayProvider && other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IntervalsForDayRef on AutoDisposeStreamProviderRef<List<TimerInterval>> {
  /// The parameter `day` of this provider.
  DateTime get day;
}

class _IntervalsForDayProviderElement
    extends AutoDisposeStreamProviderElement<List<TimerInterval>>
    with IntervalsForDayRef {
  _IntervalsForDayProviderElement(super.provider);

  @override
  DateTime get day => (origin as IntervalsForDayProvider).day;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
