import '../entities/category.dart';
import '../repositories/category_repository.dart';

class WatchCategories {
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call({bool includeArchived = false}) {
    return _repository.watchAll(includeArchived: includeArchived);
  }
}
