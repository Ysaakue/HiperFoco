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
String _$deleteTaskUseCaseHash() => r'cad91264ba65bb33ba88a524bbc74907c7c1bca2';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
