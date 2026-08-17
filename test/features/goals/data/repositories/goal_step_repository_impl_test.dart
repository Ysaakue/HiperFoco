import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';

void main() {
  late AppDatabase database;
  late GoalStepRepositoryImpl repository;
  late int goalId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GoalStepRepositoryImpl(database.goalStepDao);
    goalId = await GoalRepositoryImpl(database.goalDao).create(title: 'Learn Flutter');
  });

  tearDown(() => database.close());

  test('create appends steps in order with increasing sortOrder', () async {
    await repository.create(goalId: goalId, title: 'Read the docs');
    await repository.create(goalId: goalId, title: 'Build a todo app');
    await repository.create(goalId: goalId, title: 'Ship to the store');

    final steps = await repository.watchForGoal(goalId).first;

    expect(steps.map((s) => s.title), [
      'Read the docs',
      'Build a todo app',
      'Ship to the store',
    ]);
    expect(steps.map((s) => s.sortOrder), [0, 1, 2]);
  });

  test('watchForGoal only returns steps for that goal', () async {
    final otherGoalId =
        await GoalRepositoryImpl(database.goalDao).create(title: 'Other goal');
    await repository.create(goalId: goalId, title: 'Step A');
    await repository.create(goalId: otherGoalId, title: 'Step B');

    final steps = await repository.watchForGoal(goalId).first;

    expect(steps, hasLength(1));
    expect(steps.single.title, 'Step A');
  });

  test('setDone toggles completion', () async {
    final id = await repository.create(goalId: goalId, title: 'Step');

    await repository.setDone(id, true);
    var steps = await repository.watchForGoal(goalId).first;
    expect(steps.single.isDone, isTrue);

    await repository.setDone(id, false);
    steps = await repository.watchForGoal(goalId).first;
    expect(steps.single.isDone, isFalse);
  });

  test('reorder persists the new sortOrder for every step', () async {
    final firstId = await repository.create(goalId: goalId, title: 'First');
    final secondId = await repository.create(goalId: goalId, title: 'Second');
    final thirdId = await repository.create(goalId: goalId, title: 'Third');

    await repository.reorder([thirdId, firstId, secondId]);

    final steps = await repository.watchForGoal(goalId).first;
    expect(steps.map((s) => s.title), ['Third', 'First', 'Second']);
  });

  test('setLinkedTask marks a step as promoted', () async {
    final id = await repository.create(goalId: goalId, title: 'Step');

    await repository.setLinkedTask(id, 42);

    final steps = await repository.watchForGoal(goalId).first;
    expect(steps.single.linkedTaskId, 42);
    expect(steps.single.isPromoted, isTrue);
  });

  test('clearLinkedTask unlinks a step promoted to the given task', () async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final taskId = await TaskRepositoryImpl(database.taskDao)
        .create(title: 'Read the docs', categoryId: categoryId);
    final id = await repository.create(goalId: goalId, title: 'Read the docs');
    await repository.setLinkedTask(id, taskId);

    await repository.clearLinkedTask(taskId);

    final steps = await repository.watchForGoal(goalId).first;
    expect(steps.single.linkedTaskId, isNull);
    expect(steps.single.isPromoted, isFalse);
  });

  test('getById returns the step, or null if it does not exist', () async {
    final id = await repository.create(goalId: goalId, title: 'Step');

    final found = await repository.getById(id);
    final missing = await repository.getById(id + 999);

    expect(found?.title, 'Step');
    expect(missing, isNull);
  });

  test(
      'setDoneForLinkedTask mirrors isDone onto the step promoted to the '
      'given task, leaving unrelated steps untouched', () async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final taskId = await TaskRepositoryImpl(database.taskDao)
        .create(title: 'Read the docs', categoryId: categoryId);
    final linkedId = await repository.create(goalId: goalId, title: 'Read the docs');
    await repository.setLinkedTask(linkedId, taskId);
    final otherId = await repository.create(goalId: goalId, title: 'Other step');

    await repository.setDoneForLinkedTask(taskId, true);
    var steps = await repository.watchForGoal(goalId).first;
    expect(steps.firstWhere((s) => s.id == linkedId).isDone, isTrue);
    expect(steps.firstWhere((s) => s.id == otherId).isDone, isFalse);

    await repository.setDoneForLinkedTask(taskId, false);
    steps = await repository.watchForGoal(goalId).first;
    expect(steps.firstWhere((s) => s.id == linkedId).isDone, isFalse);
  });

  test('deleteForGoal removes every step for that goal only', () async {
    final otherGoalId =
        await GoalRepositoryImpl(database.goalDao).create(title: 'Other goal');
    await repository.create(goalId: goalId, title: 'Step A');
    await repository.create(goalId: otherGoalId, title: 'Step B');

    await repository.deleteForGoal(goalId);

    expect(await repository.watchForGoal(goalId).first, isEmpty);
    expect(await repository.watchForGoal(otherGoalId).first, hasLength(1));
  });

  test('delete removes a single step', () async {
    final id = await repository.create(goalId: goalId, title: 'Step');

    await repository.delete(id);

    expect(await repository.watchForGoal(goalId).first, isEmpty);
  });
}
