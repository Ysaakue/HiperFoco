// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRepositoryHash() => r'b2c311838bd90c9ef46971322336b42b78246380';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = Provider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = ProviderRef<TaskRepository>;
String _$watchTasksUseCaseHash() => r'503a292ce8a3f916b24cba485fa93ebbc0fe9b9d';

/// See also [watchTasksUseCase].
@ProviderFor(watchTasksUseCase)
final watchTasksUseCaseProvider = AutoDisposeProvider<WatchTasks>.internal(
  watchTasksUseCase,
  name: r'watchTasksUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchTasksUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchTasksUseCaseRef = AutoDisposeProviderRef<WatchTasks>;
String _$createTaskUseCaseHash() => r'853e41bcbfb80b116f548c8ab8f0f13ce62137d4';

/// See also [createTaskUseCase].
@ProviderFor(createTaskUseCase)
final createTaskUseCaseProvider = AutoDisposeProvider<CreateTask>.internal(
  createTaskUseCase,
  name: r'createTaskUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createTaskUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateTaskUseCaseRef = AutoDisposeProviderRef<CreateTask>;
String _$updateTaskUseCaseHash() => r'82fc14f0f3b977ed8b42a08d93a747d6486f40e3';

/// See also [updateTaskUseCase].
@ProviderFor(updateTaskUseCase)
final updateTaskUseCaseProvider = AutoDisposeProvider<UpdateTask>.internal(
  updateTaskUseCase,
  name: r'updateTaskUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateTaskUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateTaskUseCaseRef = AutoDisposeProviderRef<UpdateTask>;
String _$setTaskStatusUseCaseHash() =>
    r'83e68e5d52bcf93e4d803417ed67bccef93b77c8';

/// See also [setTaskStatusUseCase].
@ProviderFor(setTaskStatusUseCase)
final setTaskStatusUseCaseProvider =
    AutoDisposeProvider<SetTaskStatus>.internal(
      setTaskStatusUseCase,
      name: r'setTaskStatusUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$setTaskStatusUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SetTaskStatusUseCaseRef = AutoDisposeProviderRef<SetTaskStatus>;
String _$deleteTaskUseCaseHash() => r'22e6847dd20c94e7ad42eac9011767cac953117a';

/// See also [deleteTaskUseCase].
@ProviderFor(deleteTaskUseCase)
final deleteTaskUseCaseProvider = AutoDisposeProvider<DeleteTask>.internal(
  deleteTaskUseCase,
  name: r'deleteTaskUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteTaskUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteTaskUseCaseRef = AutoDisposeProviderRef<DeleteTask>;
String _$tasksListHash() => r'1d40cd8fec98e1d41c4ae0cee5d4c0e1d417ab7b';

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

/// See also [tasksList].
@ProviderFor(tasksList)
const tasksListProvider = TasksListFamily();

/// See also [tasksList].
class TasksListFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksList].
  const TasksListFamily();

  /// See also [tasksList].
  TasksListProvider call({int? categoryId, bool includeCompleted = true}) {
    return TasksListProvider(
      categoryId: categoryId,
      includeCompleted: includeCompleted,
    );
  }

  @override
  TasksListProvider getProviderOverride(covariant TasksListProvider provider) {
    return call(
      categoryId: provider.categoryId,
      includeCompleted: provider.includeCompleted,
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
  String? get name => r'tasksListProvider';
}

/// See also [tasksList].
class TasksListProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// See also [tasksList].
  TasksListProvider({int? categoryId, bool includeCompleted = true})
    : this._internal(
        (ref) => tasksList(
          ref as TasksListRef,
          categoryId: categoryId,
          includeCompleted: includeCompleted,
        ),
        from: tasksListProvider,
        name: r'tasksListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksListHash,
        dependencies: TasksListFamily._dependencies,
        allTransitiveDependencies: TasksListFamily._allTransitiveDependencies,
        categoryId: categoryId,
        includeCompleted: includeCompleted,
      );

  TasksListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.includeCompleted,
  }) : super.internal();

  final int? categoryId;
  final bool includeCompleted;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(TasksListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksListProvider._internal(
        (ref) => create(ref as TasksListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        includeCompleted: includeCompleted,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TasksListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksListProvider &&
        other.categoryId == categoryId &&
        other.includeCompleted == includeCompleted;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, includeCompleted.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksListRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;

  /// The parameter `includeCompleted` of this provider.
  bool get includeCompleted;
}

class _TasksListProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>>
    with TasksListRef {
  _TasksListProviderElement(super.provider);

  @override
  int? get categoryId => (origin as TasksListProvider).categoryId;
  @override
  bool get includeCompleted => (origin as TasksListProvider).includeCompleted;
}

String _$recurrenceRuleRepositoryHash() =>
    r'34813a6e70c5cfd70c51e74809c5ecfffe4ff411';

/// See also [recurrenceRuleRepository].
@ProviderFor(recurrenceRuleRepository)
final recurrenceRuleRepositoryProvider =
    Provider<RecurrenceRuleRepository>.internal(
      recurrenceRuleRepository,
      name: r'recurrenceRuleRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurrenceRuleRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurrenceRuleRepositoryRef = ProviderRef<RecurrenceRuleRepository>;
String _$createRecurrenceRuleUseCaseHash() =>
    r'85c9a7ae50b707b86c81e0ab3f2e5279c817a234';

/// See also [createRecurrenceRuleUseCase].
@ProviderFor(createRecurrenceRuleUseCase)
final createRecurrenceRuleUseCaseProvider =
    AutoDisposeProvider<CreateRecurrenceRule>.internal(
      createRecurrenceRuleUseCase,
      name: r'createRecurrenceRuleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createRecurrenceRuleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateRecurrenceRuleUseCaseRef =
    AutoDisposeProviderRef<CreateRecurrenceRule>;
String _$updateRecurrenceRuleUseCaseHash() =>
    r'e623c7147242ac2097829f1379a52346356cb6e9';

/// See also [updateRecurrenceRuleUseCase].
@ProviderFor(updateRecurrenceRuleUseCase)
final updateRecurrenceRuleUseCaseProvider =
    AutoDisposeProvider<UpdateRecurrenceRule>.internal(
      updateRecurrenceRuleUseCase,
      name: r'updateRecurrenceRuleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateRecurrenceRuleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateRecurrenceRuleUseCaseRef =
    AutoDisposeProviderRef<UpdateRecurrenceRule>;
String _$deleteRecurrenceRuleUseCaseHash() =>
    r'2be3a43d009b7540555d524e61e4bf8a5a1e7afe';

/// See also [deleteRecurrenceRuleUseCase].
@ProviderFor(deleteRecurrenceRuleUseCase)
final deleteRecurrenceRuleUseCaseProvider =
    AutoDisposeProvider<DeleteRecurrenceRule>.internal(
      deleteRecurrenceRuleUseCase,
      name: r'deleteRecurrenceRuleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteRecurrenceRuleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteRecurrenceRuleUseCaseRef =
    AutoDisposeProviderRef<DeleteRecurrenceRule>;
String _$getRecurrenceRuleUseCaseHash() =>
    r'73408643cce7ab64e5ed71c7adc07eba46e242fa';

/// See also [getRecurrenceRuleUseCase].
@ProviderFor(getRecurrenceRuleUseCase)
final getRecurrenceRuleUseCaseProvider =
    AutoDisposeProvider<GetRecurrenceRule>.internal(
      getRecurrenceRuleUseCase,
      name: r'getRecurrenceRuleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getRecurrenceRuleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetRecurrenceRuleUseCaseRef = AutoDisposeProviderRef<GetRecurrenceRule>;
String _$recurrenceRuleByIdHash() =>
    r'3138a1a85f80ae1f3f58f680afc2c4cdfe90293f';

/// See also [recurrenceRuleById].
@ProviderFor(recurrenceRuleById)
const recurrenceRuleByIdProvider = RecurrenceRuleByIdFamily();

/// See also [recurrenceRuleById].
class RecurrenceRuleByIdFamily extends Family<AsyncValue<RecurrenceRule?>> {
  /// See also [recurrenceRuleById].
  const RecurrenceRuleByIdFamily();

  /// See also [recurrenceRuleById].
  RecurrenceRuleByIdProvider call(int id) {
    return RecurrenceRuleByIdProvider(id);
  }

  @override
  RecurrenceRuleByIdProvider getProviderOverride(
    covariant RecurrenceRuleByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recurrenceRuleByIdProvider';
}

/// See also [recurrenceRuleById].
class RecurrenceRuleByIdProvider
    extends AutoDisposeFutureProvider<RecurrenceRule?> {
  /// See also [recurrenceRuleById].
  RecurrenceRuleByIdProvider(int id)
    : this._internal(
        (ref) => recurrenceRuleById(ref as RecurrenceRuleByIdRef, id),
        from: recurrenceRuleByIdProvider,
        name: r'recurrenceRuleByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recurrenceRuleByIdHash,
        dependencies: RecurrenceRuleByIdFamily._dependencies,
        allTransitiveDependencies:
            RecurrenceRuleByIdFamily._allTransitiveDependencies,
        id: id,
      );

  RecurrenceRuleByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<RecurrenceRule?> Function(RecurrenceRuleByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecurrenceRuleByIdProvider._internal(
        (ref) => create(ref as RecurrenceRuleByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecurrenceRule?> createElement() {
    return _RecurrenceRuleByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurrenceRuleByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecurrenceRuleByIdRef on AutoDisposeFutureProviderRef<RecurrenceRule?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _RecurrenceRuleByIdProviderElement
    extends AutoDisposeFutureProviderElement<RecurrenceRule?>
    with RecurrenceRuleByIdRef {
  _RecurrenceRuleByIdProviderElement(super.provider);

  @override
  int get id => (origin as RecurrenceRuleByIdProvider).id;
}

String _$taskOccurrenceOverrideRepositoryHash() =>
    r'4dddc840603ddad9aa5cf1e56dbbe060da8c2cf7';

/// See also [taskOccurrenceOverrideRepository].
@ProviderFor(taskOccurrenceOverrideRepository)
final taskOccurrenceOverrideRepositoryProvider =
    Provider<TaskOccurrenceOverrideRepository>.internal(
      taskOccurrenceOverrideRepository,
      name: r'taskOccurrenceOverrideRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskOccurrenceOverrideRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskOccurrenceOverrideRepositoryRef =
    ProviderRef<TaskOccurrenceOverrideRepository>;
String _$setOccurrenceStatusUseCaseHash() =>
    r'8da40cee9eb9403dace84aa708baf5ef45dbf92d';

/// See also [setOccurrenceStatusUseCase].
@ProviderFor(setOccurrenceStatusUseCase)
final setOccurrenceStatusUseCaseProvider =
    AutoDisposeProvider<SetOccurrenceStatus>.internal(
      setOccurrenceStatusUseCase,
      name: r'setOccurrenceStatusUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$setOccurrenceStatusUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SetOccurrenceStatusUseCaseRef =
    AutoDisposeProviderRef<SetOccurrenceStatus>;
String _$clearOccurrenceOverrideUseCaseHash() =>
    r'a71b180082d7196dff9283ca7be835a9d2148119';

/// See also [clearOccurrenceOverrideUseCase].
@ProviderFor(clearOccurrenceOverrideUseCase)
final clearOccurrenceOverrideUseCaseProvider =
    AutoDisposeProvider<ClearOccurrenceOverride>.internal(
      clearOccurrenceOverrideUseCase,
      name: r'clearOccurrenceOverrideUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clearOccurrenceOverrideUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClearOccurrenceOverrideUseCaseRef =
    AutoDisposeProviderRef<ClearOccurrenceOverride>;
String _$watchOccurrenceOverridesBetweenUseCaseHash() =>
    r'8d30ab29429c5d0ec2da48691330e0f68287190f';

/// See also [watchOccurrenceOverridesBetweenUseCase].
@ProviderFor(watchOccurrenceOverridesBetweenUseCase)
final watchOccurrenceOverridesBetweenUseCaseProvider =
    AutoDisposeProvider<WatchOccurrenceOverridesBetween>.internal(
      watchOccurrenceOverridesBetweenUseCase,
      name: r'watchOccurrenceOverridesBetweenUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchOccurrenceOverridesBetweenUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchOccurrenceOverridesBetweenUseCaseRef =
    AutoDisposeProviderRef<WatchOccurrenceOverridesBetween>;
String _$occurrenceOverridesBetweenHash() =>
    r'62a04ca2bb01d758ca867fad6df11f49f6952dd9';

/// See also [occurrenceOverridesBetween].
@ProviderFor(occurrenceOverridesBetween)
const occurrenceOverridesBetweenProvider = OccurrenceOverridesBetweenFamily();

/// See also [occurrenceOverridesBetween].
class OccurrenceOverridesBetweenFamily
    extends Family<AsyncValue<List<TaskOccurrenceOverride>>> {
  /// See also [occurrenceOverridesBetween].
  const OccurrenceOverridesBetweenFamily();

  /// See also [occurrenceOverridesBetween].
  OccurrenceOverridesBetweenProvider call(DateTime start, DateTime end) {
    return OccurrenceOverridesBetweenProvider(start, end);
  }

  @override
  OccurrenceOverridesBetweenProvider getProviderOverride(
    covariant OccurrenceOverridesBetweenProvider provider,
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
  String? get name => r'occurrenceOverridesBetweenProvider';
}

/// See also [occurrenceOverridesBetween].
class OccurrenceOverridesBetweenProvider
    extends AutoDisposeStreamProvider<List<TaskOccurrenceOverride>> {
  /// See also [occurrenceOverridesBetween].
  OccurrenceOverridesBetweenProvider(DateTime start, DateTime end)
    : this._internal(
        (ref) => occurrenceOverridesBetween(
          ref as OccurrenceOverridesBetweenRef,
          start,
          end,
        ),
        from: occurrenceOverridesBetweenProvider,
        name: r'occurrenceOverridesBetweenProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$occurrenceOverridesBetweenHash,
        dependencies: OccurrenceOverridesBetweenFamily._dependencies,
        allTransitiveDependencies:
            OccurrenceOverridesBetweenFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  OccurrenceOverridesBetweenProvider._internal(
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
    Stream<List<TaskOccurrenceOverride>> Function(
      OccurrenceOverridesBetweenRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OccurrenceOverridesBetweenProvider._internal(
        (ref) => create(ref as OccurrenceOverridesBetweenRef),
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
  AutoDisposeStreamProviderElement<List<TaskOccurrenceOverride>>
  createElement() {
    return _OccurrenceOverridesBetweenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OccurrenceOverridesBetweenProvider &&
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
mixin OccurrenceOverridesBetweenRef
    on AutoDisposeStreamProviderRef<List<TaskOccurrenceOverride>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _OccurrenceOverridesBetweenProviderElement
    extends AutoDisposeStreamProviderElement<List<TaskOccurrenceOverride>>
    with OccurrenceOverridesBetweenRef {
  _OccurrenceOverridesBetweenProviderElement(super.provider);

  @override
  DateTime get start => (origin as OccurrenceOverridesBetweenProvider).start;
  @override
  DateTime get end => (origin as OccurrenceOverridesBetweenProvider).end;
}

String _$occurrencesForRangeHash() =>
    r'1d09310868a36a862dc5d722023a18b1dc34f254';

/// Combines recurring/non-recurring tasks, their recurrence rules, and any
/// per-occurrence overrides into the flat list a calendar view renders.
///
/// Copied from [occurrencesForRange].
@ProviderFor(occurrencesForRange)
const occurrencesForRangeProvider = OccurrencesForRangeFamily();

/// Combines recurring/non-recurring tasks, their recurrence rules, and any
/// per-occurrence overrides into the flat list a calendar view renders.
///
/// Copied from [occurrencesForRange].
class OccurrencesForRangeFamily
    extends Family<AsyncValue<List<TaskOccurrence>>> {
  /// Combines recurring/non-recurring tasks, their recurrence rules, and any
  /// per-occurrence overrides into the flat list a calendar view renders.
  ///
  /// Copied from [occurrencesForRange].
  const OccurrencesForRangeFamily();

  /// Combines recurring/non-recurring tasks, their recurrence rules, and any
  /// per-occurrence overrides into the flat list a calendar view renders.
  ///
  /// Copied from [occurrencesForRange].
  OccurrencesForRangeProvider call(DateTime start, DateTime end) {
    return OccurrencesForRangeProvider(start, end);
  }

  @override
  OccurrencesForRangeProvider getProviderOverride(
    covariant OccurrencesForRangeProvider provider,
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
  String? get name => r'occurrencesForRangeProvider';
}

/// Combines recurring/non-recurring tasks, their recurrence rules, and any
/// per-occurrence overrides into the flat list a calendar view renders.
///
/// Copied from [occurrencesForRange].
class OccurrencesForRangeProvider
    extends AutoDisposeStreamProvider<List<TaskOccurrence>> {
  /// Combines recurring/non-recurring tasks, their recurrence rules, and any
  /// per-occurrence overrides into the flat list a calendar view renders.
  ///
  /// Copied from [occurrencesForRange].
  OccurrencesForRangeProvider(DateTime start, DateTime end)
    : this._internal(
        (ref) => occurrencesForRange(ref as OccurrencesForRangeRef, start, end),
        from: occurrencesForRangeProvider,
        name: r'occurrencesForRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$occurrencesForRangeHash,
        dependencies: OccurrencesForRangeFamily._dependencies,
        allTransitiveDependencies:
            OccurrencesForRangeFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  OccurrencesForRangeProvider._internal(
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
    Stream<List<TaskOccurrence>> Function(OccurrencesForRangeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OccurrencesForRangeProvider._internal(
        (ref) => create(ref as OccurrencesForRangeRef),
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
  AutoDisposeStreamProviderElement<List<TaskOccurrence>> createElement() {
    return _OccurrencesForRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OccurrencesForRangeProvider &&
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
mixin OccurrencesForRangeRef
    on AutoDisposeStreamProviderRef<List<TaskOccurrence>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _OccurrencesForRangeProviderElement
    extends AutoDisposeStreamProviderElement<List<TaskOccurrence>>
    with OccurrencesForRangeRef {
  _OccurrencesForRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as OccurrencesForRangeProvider).start;
  @override
  DateTime get end => (origin as OccurrencesForRangeProvider).end;
}

String _$reminderRepositoryHash() =>
    r'b0da48dfb84e34ea2a78e4d96b3f3277f2a9c349';

/// See also [reminderRepository].
@ProviderFor(reminderRepository)
final reminderRepositoryProvider = Provider<ReminderRepository>.internal(
  reminderRepository,
  name: r'reminderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reminderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReminderRepositoryRef = ProviderRef<ReminderRepository>;
String _$createReminderUseCaseHash() =>
    r'ba04fb5f91229161c5604becb9399d3156eadb55';

/// See also [createReminderUseCase].
@ProviderFor(createReminderUseCase)
final createReminderUseCaseProvider =
    AutoDisposeProvider<CreateReminder>.internal(
      createReminderUseCase,
      name: r'createReminderUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createReminderUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateReminderUseCaseRef = AutoDisposeProviderRef<CreateReminder>;
String _$updateReminderUseCaseHash() =>
    r'a63d1ad6ebd954b96d50093966d1dedac588482f';

/// See also [updateReminderUseCase].
@ProviderFor(updateReminderUseCase)
final updateReminderUseCaseProvider =
    AutoDisposeProvider<UpdateReminder>.internal(
      updateReminderUseCase,
      name: r'updateReminderUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateReminderUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateReminderUseCaseRef = AutoDisposeProviderRef<UpdateReminder>;
String _$deleteReminderUseCaseHash() =>
    r'a2690845061efcdfc783eaa6a1d90006cc998070';

/// See also [deleteReminderUseCase].
@ProviderFor(deleteReminderUseCase)
final deleteReminderUseCaseProvider =
    AutoDisposeProvider<DeleteReminder>.internal(
      deleteReminderUseCase,
      name: r'deleteReminderUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteReminderUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteReminderUseCaseRef = AutoDisposeProviderRef<DeleteReminder>;
String _$watchRemindersUseCaseHash() =>
    r'2d5296094175449eafb184dbe631f812ea7937ca';

/// See also [watchRemindersUseCase].
@ProviderFor(watchRemindersUseCase)
final watchRemindersUseCaseProvider =
    AutoDisposeProvider<WatchReminders>.internal(
      watchRemindersUseCase,
      name: r'watchRemindersUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchRemindersUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchRemindersUseCaseRef = AutoDisposeProviderRef<WatchReminders>;
String _$watchStandaloneRemindersUseCaseHash() =>
    r'55a186728bf2db08f81bce5770645bb75ceb6f8c';

/// See also [watchStandaloneRemindersUseCase].
@ProviderFor(watchStandaloneRemindersUseCase)
final watchStandaloneRemindersUseCaseProvider =
    AutoDisposeProvider<WatchStandaloneReminders>.internal(
      watchStandaloneRemindersUseCase,
      name: r'watchStandaloneRemindersUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchStandaloneRemindersUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchStandaloneRemindersUseCaseRef =
    AutoDisposeProviderRef<WatchStandaloneReminders>;
String _$watchReminderForTaskUseCaseHash() =>
    r'd735fe18bf44f18b5774c4775fa0432405131978';

/// See also [watchReminderForTaskUseCase].
@ProviderFor(watchReminderForTaskUseCase)
final watchReminderForTaskUseCaseProvider =
    AutoDisposeProvider<WatchReminderForTask>.internal(
      watchReminderForTaskUseCase,
      name: r'watchReminderForTaskUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchReminderForTaskUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchReminderForTaskUseCaseRef =
    AutoDisposeProviderRef<WatchReminderForTask>;
String _$remindersListHash() => r'ec6d1327a6e1a0e1f4e9ce8b68e7f2f43f9540b1';

/// See also [remindersList].
@ProviderFor(remindersList)
final remindersListProvider =
    AutoDisposeStreamProvider<List<Reminder>>.internal(
      remindersList,
      name: r'remindersListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$remindersListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemindersListRef = AutoDisposeStreamProviderRef<List<Reminder>>;
String _$standaloneRemindersListHash() =>
    r'bf335c85c8bc61ad4e24e17abd9ce4189926052a';

/// See also [standaloneRemindersList].
@ProviderFor(standaloneRemindersList)
final standaloneRemindersListProvider =
    AutoDisposeStreamProvider<List<Reminder>>.internal(
      standaloneRemindersList,
      name: r'standaloneRemindersListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$standaloneRemindersListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StandaloneRemindersListRef =
    AutoDisposeStreamProviderRef<List<Reminder>>;
String _$reminderForTaskHash() => r'b73556688b2a7aa5321a47b44c0523690591407a';

/// See also [reminderForTask].
@ProviderFor(reminderForTask)
const reminderForTaskProvider = ReminderForTaskFamily();

/// See also [reminderForTask].
class ReminderForTaskFamily extends Family<AsyncValue<Reminder?>> {
  /// See also [reminderForTask].
  const ReminderForTaskFamily();

  /// See also [reminderForTask].
  ReminderForTaskProvider call(int taskId) {
    return ReminderForTaskProvider(taskId);
  }

  @override
  ReminderForTaskProvider getProviderOverride(
    covariant ReminderForTaskProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reminderForTaskProvider';
}

/// See also [reminderForTask].
class ReminderForTaskProvider extends AutoDisposeStreamProvider<Reminder?> {
  /// See also [reminderForTask].
  ReminderForTaskProvider(int taskId)
    : this._internal(
        (ref) => reminderForTask(ref as ReminderForTaskRef, taskId),
        from: reminderForTaskProvider,
        name: r'reminderForTaskProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reminderForTaskHash,
        dependencies: ReminderForTaskFamily._dependencies,
        allTransitiveDependencies:
            ReminderForTaskFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  ReminderForTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(
    Stream<Reminder?> Function(ReminderForTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderForTaskProvider._internal(
        (ref) => create(ref as ReminderForTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Reminder?> createElement() {
    return _ReminderForTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderForTaskProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReminderForTaskRef on AutoDisposeStreamProviderRef<Reminder?> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _ReminderForTaskProviderElement
    extends AutoDisposeStreamProviderElement<Reminder?>
    with ReminderForTaskRef {
  _ReminderForTaskProviderElement(super.provider);

  @override
  int get taskId => (origin as ReminderForTaskProvider).taskId;
}

String _$notificationSchedulerHash() =>
    r'2b38209638403a6666bec1cf7f23b973fc0b2dd7';

/// See also [notificationScheduler].
@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = Provider<NotificationScheduler>.internal(
  notificationScheduler,
  name: r'notificationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationSchedulerRef = ProviderRef<NotificationScheduler>;
String _$reminderSchedulingServiceHash() =>
    r'c23c8fbcb9ea8616dce6f24f5505dea5603ee388';

/// See also [reminderSchedulingService].
@ProviderFor(reminderSchedulingService)
final reminderSchedulingServiceProvider =
    Provider<ReminderSchedulingService>.internal(
      reminderSchedulingService,
      name: r'reminderSchedulingServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reminderSchedulingServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReminderSchedulingServiceRef = ProviderRef<ReminderSchedulingService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
