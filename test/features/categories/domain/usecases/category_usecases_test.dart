import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/categories/domain/entities/category.dart';
import 'package:hiperfoco/features/categories/domain/repositories/category_repository.dart';
import 'package:hiperfoco/features/categories/domain/usecases/create_category.dart';
import 'package:hiperfoco/features/categories/domain/usecases/set_category_archived.dart';
import 'package:hiperfoco/features/categories/domain/usecases/update_category.dart';
import 'package:hiperfoco/features/categories/domain/usecases/watch_categories.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository repository;

  final category = Category(
    id: 1,
    name: 'Work',
    colorValue: 0xFF7C5CFC,
    iconKey: 'work',
    isArchived: false,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockCategoryRepository();
  });

  group('WatchCategories', () {
    test('delegates to repository.watchAll with the given flag', () {
      when(() => repository.watchAll(includeArchived: true))
          .thenAnswer((_) => Stream.value([category]));

      final stream = WatchCategories(repository)(includeArchived: true);

      expect(stream, emits([category]));
      verify(() => repository.watchAll(includeArchived: true)).called(1);
    });

    test('defaults to includeArchived: false', () {
      when(() => repository.watchAll(includeArchived: false))
          .thenAnswer((_) => Stream.value(const []));

      WatchCategories(repository)();

      verify(() => repository.watchAll(includeArchived: false)).called(1);
    });
  });

  group('CreateCategory', () {
    test('delegates to repository.create with the given fields', () async {
      when(() => repository.create(
            name: 'Work',
            colorValue: 0xFF7C5CFC,
            iconKey: 'work',
          )).thenAnswer((_) async => 1);

      final id = await CreateCategory(repository)(
        name: 'Work',
        colorValue: 0xFF7C5CFC,
        iconKey: 'work',
      );

      expect(id, 1);
      verify(() => repository.create(
            name: 'Work',
            colorValue: 0xFF7C5CFC,
            iconKey: 'work',
          )).called(1);
    });
  });

  group('UpdateCategory', () {
    test('delegates to repository.update with the category', () async {
      when(() => repository.update(category)).thenAnswer((_) async {});

      await UpdateCategory(repository)(category);

      verify(() => repository.update(category)).called(1);
    });
  });

  group('SetCategoryArchived', () {
    test('delegates to repository.setArchived', () async {
      when(() => repository.setArchived(1, true)).thenAnswer((_) async {});

      await SetCategoryArchived(repository)(1, true);

      verify(() => repository.setArchived(1, true)).called(1);
    });
  });
}
