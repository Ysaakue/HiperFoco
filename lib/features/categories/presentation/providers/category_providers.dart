import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/set_category_archived.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/watch_categories.dart';

part 'category_providers.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).categoryDao;
  return CategoryRepositoryImpl(dao);
}

@riverpod
WatchCategories watchCategoriesUseCase(Ref ref) {
  return WatchCategories(ref.watch(categoryRepositoryProvider));
}

@riverpod
CreateCategory createCategoryUseCase(Ref ref) {
  return CreateCategory(ref.watch(categoryRepositoryProvider));
}

@riverpod
UpdateCategory updateCategoryUseCase(Ref ref) {
  return UpdateCategory(ref.watch(categoryRepositoryProvider));
}

@riverpod
SetCategoryArchived setCategoryArchivedUseCase(Ref ref) {
  return SetCategoryArchived(ref.watch(categoryRepositoryProvider));
}

@riverpod
Stream<List<Category>> categoriesList(Ref ref, {bool includeArchived = false}) {
  return ref.watch(watchCategoriesUseCaseProvider)(includeArchived: includeArchived);
}
