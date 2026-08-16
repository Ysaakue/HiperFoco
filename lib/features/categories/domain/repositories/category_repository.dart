import '../entities/category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll({bool includeArchived = false});

  Future<Category?> getById(int id);

  Future<int> create({
    required String name,
    required int colorValue,
    required String iconKey,
  });

  Future<void> update(Category category);

  Future<void> setArchived(int id, bool archived);
}
