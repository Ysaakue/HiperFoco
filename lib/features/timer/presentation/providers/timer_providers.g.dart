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

String _$archivedDayHash() => r'03f85e77f9dec6bfe57f8ed4c99467d5bc0c04ae';

/// See also [archivedDay].
@ProviderFor(archivedDay)
const archivedDayProvider = ArchivedDayFamily();

/// See also [archivedDay].
class ArchivedDayFamily extends Family<AsyncValue<List<TimerHistoryEntry>>> {
  /// See also [archivedDay].
  const ArchivedDayFamily();

  /// See also [archivedDay].
  ArchivedDayProvider call(DateTime day) {
    return ArchivedDayProvider(day);
  }

  @override
  ArchivedDayProvider getProviderOverride(
    covariant ArchivedDayProvider provider,
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
  String? get name => r'archivedDayProvider';
}

/// See also [archivedDay].
class ArchivedDayProvider
    extends AutoDisposeStreamProvider<List<TimerHistoryEntry>> {
  /// See also [archivedDay].
  ArchivedDayProvider(DateTime day)
    : this._internal(
        (ref) => archivedDay(ref as ArchivedDayRef, day),
        from: archivedDayProvider,
        name: r'archivedDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$archivedDayHash,
        dependencies: ArchivedDayFamily._dependencies,
        allTransitiveDependencies: ArchivedDayFamily._allTransitiveDependencies,
        day: day,
      );

  ArchivedDayProvider._internal(
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
    Stream<List<TimerHistoryEntry>> Function(ArchivedDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArchivedDayProvider._internal(
        (ref) => create(ref as ArchivedDayRef),
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
  AutoDisposeStreamProviderElement<List<TimerHistoryEntry>> createElement() {
    return _ArchivedDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArchivedDayProvider && other.day == day;
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
mixin ArchivedDayRef on AutoDisposeStreamProviderRef<List<TimerHistoryEntry>> {
  /// The parameter `day` of this provider.
  DateTime get day;
}

class _ArchivedDayProviderElement
    extends AutoDisposeStreamProviderElement<List<TimerHistoryEntry>>
    with ArchivedDayRef {
  _ArchivedDayProviderElement(super.provider);

  @override
  DateTime get day => (origin as ArchivedDayProvider).day;
}

String _$archivedBetweenHash() => r'27d7f74ac227ce417304ba3117c540235c563429';

/// See also [archivedBetween].
@ProviderFor(archivedBetween)
const archivedBetweenProvider = ArchivedBetweenFamily();

/// See also [archivedBetween].
class ArchivedBetweenFamily
    extends Family<AsyncValue<List<TimerHistoryEntry>>> {
  /// See also [archivedBetween].
  const ArchivedBetweenFamily();

  /// See also [archivedBetween].
  ArchivedBetweenProvider call(DateTime start, DateTime end) {
    return ArchivedBetweenProvider(start, end);
  }

  @override
  ArchivedBetweenProvider getProviderOverride(
    covariant ArchivedBetweenProvider provider,
  ) {
    return call(provider.start, provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'archivedBetweenProvider';
}

/// See also [archivedBetween].
class ArchivedBetweenProvider
    extends AutoDisposeStreamProvider<List<TimerHistoryEntry>> {
  /// See also [archivedBetween].
  ArchivedBetweenProvider(DateTime start, DateTime end)
    : this._internal(
        (ref) => archivedBetween(ref as ArchivedBetweenRef, start, end),
        from: archivedBetweenProvider,
        name: r'archivedBetweenProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$archivedBetweenHash,
        dependencies: ArchivedBetweenFamily._dependencies,
        allTransitiveDependencies:
            ArchivedBetweenFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  ArchivedBetweenProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    Stream<List<TimerHistoryEntry>> Function(ArchivedBetweenRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArchivedBetweenProvider._internal(
        (ref) => create(ref as ArchivedBetweenRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimerHistoryEntry>> createElement() {
    return _ArchivedBetweenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArchivedBetweenProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArchivedBetweenRef
    on AutoDisposeStreamProviderRef<List<TimerHistoryEntry>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _ArchivedBetweenProviderElement
    extends AutoDisposeStreamProviderElement<List<TimerHistoryEntry>>
    with ArchivedBetweenRef {
  _ArchivedBetweenProviderElement(super.provider);

  @override
  DateTime get start => (origin as ArchivedBetweenProvider).start;
  @override
  DateTime get end => (origin as ArchivedBetweenProvider).end;
}

String _$archiveStateRepositoryHash() =>
    r'a0aab3e730a9a07bc2129dbc6fa07100e28d3ede';

/// See also [archiveStateRepository].
@ProviderFor(archiveStateRepository)
final archiveStateRepositoryProvider =
    Provider<ArchiveStateRepository>.internal(
      archiveStateRepository,
      name: r'archiveStateRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archiveStateRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchiveStateRepositoryRef = ProviderRef<ArchiveStateRepository>;
String _$dailyArchiveServiceHash() =>
    r'fa8aa75b427192e82eb7afe255604f46a9af956e';

/// See also [dailyArchiveService].
@ProviderFor(dailyArchiveService)
final dailyArchiveServiceProvider = Provider<DailyArchiveService>.internal(
  dailyArchiveService,
  name: r'dailyArchiveServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyArchiveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyArchiveServiceRef = ProviderRef<DailyArchiveService>;
String _$purgeOldDataUseCaseHash() =>
    r'2e47f0c855fd7490dd05e59e43ed2afff62677f5';

/// See also [purgeOldDataUseCase].
@ProviderFor(purgeOldDataUseCase)
final purgeOldDataUseCaseProvider = AutoDisposeProvider<PurgeOldData>.internal(
  purgeOldDataUseCase,
  name: r'purgeOldDataUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purgeOldDataUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PurgeOldDataUseCaseRef = AutoDisposeProviderRef<PurgeOldData>;
String _$retentionMonthsControllerHash() =>
    r'ce559e290a36afa8ab164d693fdd76532597aef1';

/// See also [RetentionMonthsController].
@ProviderFor(RetentionMonthsController)
final retentionMonthsControllerProvider =
    NotifierProvider<RetentionMonthsController, int>.internal(
      RetentionMonthsController.new,
      name: r'retentionMonthsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$retentionMonthsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RetentionMonthsController = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
