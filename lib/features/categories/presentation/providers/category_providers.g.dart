// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'f64df53e04d5f609c143ad17a7c9507ed1f94601';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider = Provider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = ProviderRef<CategoryRepository>;
String _$watchCategoriesUseCaseHash() =>
    r'd3fecf1b62bb672c03480d92ea37ffbe386adcaa';

/// See also [watchCategoriesUseCase].
@ProviderFor(watchCategoriesUseCase)
final watchCategoriesUseCaseProvider =
    AutoDisposeProvider<WatchCategories>.internal(
      watchCategoriesUseCase,
      name: r'watchCategoriesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchCategoriesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchCategoriesUseCaseRef = AutoDisposeProviderRef<WatchCategories>;
String _$createCategoryUseCaseHash() =>
    r'cf2358c957221be00e0beb35f36116e1d46ed5e8';

/// See also [createCategoryUseCase].
@ProviderFor(createCategoryUseCase)
final createCategoryUseCaseProvider =
    AutoDisposeProvider<CreateCategory>.internal(
      createCategoryUseCase,
      name: r'createCategoryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createCategoryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateCategoryUseCaseRef = AutoDisposeProviderRef<CreateCategory>;
String _$updateCategoryUseCaseHash() =>
    r'6525da4cbd667c52d0f8bb009ac8c3e2130d31ed';

/// See also [updateCategoryUseCase].
@ProviderFor(updateCategoryUseCase)
final updateCategoryUseCaseProvider =
    AutoDisposeProvider<UpdateCategory>.internal(
      updateCategoryUseCase,
      name: r'updateCategoryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateCategoryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateCategoryUseCaseRef = AutoDisposeProviderRef<UpdateCategory>;
String _$setCategoryArchivedUseCaseHash() =>
    r'93854808a72906030a21b24d18fb6c4982b43881';

/// See also [setCategoryArchivedUseCase].
@ProviderFor(setCategoryArchivedUseCase)
final setCategoryArchivedUseCaseProvider =
    AutoDisposeProvider<SetCategoryArchived>.internal(
      setCategoryArchivedUseCase,
      name: r'setCategoryArchivedUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$setCategoryArchivedUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SetCategoryArchivedUseCaseRef =
    AutoDisposeProviderRef<SetCategoryArchived>;
String _$categoriesListHash() => r'2ec9d5fd5554b03b6edb4b5081729466a6ac56a4';

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

/// See also [categoriesList].
@ProviderFor(categoriesList)
const categoriesListProvider = CategoriesListFamily();

/// See also [categoriesList].
class CategoriesListFamily extends Family<AsyncValue<List<Category>>> {
  /// See also [categoriesList].
  const CategoriesListFamily();

  /// See also [categoriesList].
  CategoriesListProvider call({bool includeArchived = false}) {
    return CategoriesListProvider(includeArchived: includeArchived);
  }

  @override
  CategoriesListProvider getProviderOverride(
    covariant CategoriesListProvider provider,
  ) {
    return call(includeArchived: provider.includeArchived);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoriesListProvider';
}

/// See also [categoriesList].
class CategoriesListProvider extends AutoDisposeStreamProvider<List<Category>> {
  /// See also [categoriesList].
  CategoriesListProvider({bool includeArchived = false})
    : this._internal(
        (ref) => categoriesList(
          ref as CategoriesListRef,
          includeArchived: includeArchived,
        ),
        from: categoriesListProvider,
        name: r'categoriesListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoriesListHash,
        dependencies: CategoriesListFamily._dependencies,
        allTransitiveDependencies:
            CategoriesListFamily._allTransitiveDependencies,
        includeArchived: includeArchived,
      );

  CategoriesListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.includeArchived,
  }) : super.internal();

  final bool includeArchived;

  @override
  Override overrideWith(
    Stream<List<Category>> Function(CategoriesListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesListProvider._internal(
        (ref) => create(ref as CategoriesListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        includeArchived: includeArchived,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Category>> createElement() {
    return _CategoriesListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesListProvider &&
        other.includeArchived == includeArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, includeArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoriesListRef on AutoDisposeStreamProviderRef<List<Category>> {
  /// The parameter `includeArchived` of this provider.
  bool get includeArchived;
}

class _CategoriesListProviderElement
    extends AutoDisposeStreamProviderElement<List<Category>>
    with CategoriesListRef {
  _CategoriesListProviderElement(super.provider);

  @override
  bool get includeArchived =>
      (origin as CategoriesListProvider).includeArchived;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
