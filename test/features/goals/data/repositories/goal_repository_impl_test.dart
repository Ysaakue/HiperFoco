import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';

void main() {
  late AppDatabase database;
  late GoalRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GoalRepositoryImpl(database.goalDao);
  });

  tearDown(() => database.close());

  test('create persists a goal retrievable via watchAll', () async {
    final id = await repository.create(
      title: 'Learn Flutter',
      description: 'Build a real app end to end',
    );

    final goals = await repository.watchAll().first;

    expect(goals, hasLength(1));
    expect(goals.single.id, id);
    expect(goals.single.title, 'Learn Flutter');
    expect(goals.single.description, 'Build a real app end to end');
  });

  test('create with no description leaves it null', () async {
    final id = await repository.create(title: 'Run a 10k');

    final goal = await repository.getById(id);

    expect(goal!.description, isNull);
  });

  test('update persists changed fields', () async {
    final id = await repository.create(title: 'Old title');
    final goal = await repository.getById(id);

    await repository.update(
      goal!.copyWith(title: 'New title', description: 'Added later'),
    );

    final updated = await repository.getById(id);
    expect(updated!.title, 'New title');
    expect(updated.description, 'Added later');
  });

  test('delete removes the goal', () async {
    final id = await repository.create(title: 'Temporary');

    await repository.delete(id);

    expect(await repository.getById(id), isNull);
  });

  test('getById returns null for an unknown id', () async {
    expect(await repository.getById(999), isNull);
  });
}
