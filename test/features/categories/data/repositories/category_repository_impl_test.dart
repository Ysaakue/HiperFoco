import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';

void main() {
  late AppDatabase database;
  late CategoryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CategoryRepositoryImpl(database.categoryDao);
  });

  tearDown(() => database.close());

  test('create persists a category retrievable via watchAll', () async {
    final id = await repository.create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );

    final categories = await repository.watchAll().first;

    expect(categories, hasLength(1));
    expect(categories.single.id, id);
    expect(categories.single.name, 'Work');
    expect(categories.single.colorValue, 0xFF7C5CFC);
    expect(categories.single.iconKey, 'work');
    expect(categories.single.isArchived, isFalse);
  });

  test('watchAll excludes archived categories by default', () async {
    final id = await repository.create(
      name: 'Old',
      colorValue: 0xFF000000,
      iconKey: 'other',
    );
    await repository.setArchived(id, true);

    final visible = await repository.watchAll().first;
    final withArchived = await repository.watchAll(includeArchived: true).first;

    expect(visible, isEmpty);
    expect(withArchived, hasLength(1));
    expect(withArchived.single.isArchived, isTrue);
  });

  test('setArchived(false) restores a category to the default view', () async {
    final id = await repository.create(
      name: 'Old',
      colorValue: 0xFF000000,
      iconKey: 'other',
    );
    await repository.setArchived(id, true);
    await repository.setArchived(id, false);

    final visible = await repository.watchAll().first;

    expect(visible.single.id, id);
    expect(visible.single.isArchived, isFalse);
  });

  test('update persists changed fields', () async {
    final id = await repository.create(
      name: 'Study',
      colorValue: 0xFF000000,
      iconKey: 'study',
    );
    final category = await repository.getById(id);

    await repository.update(
      category!.copyWith(name: 'School', colorValue: 0xFF123456),
    );

    final updated = await repository.getById(id);
    expect(updated!.name, 'School');
    expect(updated.colorValue, 0xFF123456);
  });

  test('getById returns null for an unknown id', () async {
    final result = await repository.getById(999);
    expect(result, isNull);
  });
}
