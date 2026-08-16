import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/category_dao.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao);

  final CategoryDao _dao;

  @override
  Stream<List<Category>> watchAll({bool includeArchived = false}) {
    return _dao
        .watchAll(includeArchived: includeArchived)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Category?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create({
    required String name,
    required int colorValue,
    required String iconKey,
  }) {
    return _dao.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        colorValue: colorValue,
        iconKey: iconKey,
      ),
    );
  }

  @override
  Future<void> update(Category category) {
    return _dao.updateCategory(
      CategoriesCompanion(
        id: Value(category.id),
        name: Value(category.name),
        colorValue: Value(category.colorValue),
        iconKey: Value(category.iconKey),
        isArchived: Value(category.isArchived),
      ),
    );
  }

  @override
  Future<void> setArchived(int id, bool archived) {
    return _dao.setArchived(id, archived);
  }

  Category _toEntity(CategoryRow row) {
    return Category(
      id: row.id,
      name: row.name,
      colorValue: row.colorValue,
      iconKey: row.iconKey,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
    );
  }
}
