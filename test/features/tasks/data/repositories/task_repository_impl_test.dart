import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';

void main() {
  late AppDatabase database;
  late TaskRepositoryImpl repository;
  late CategoryRepositoryImpl categoryRepository;
  late int categoryId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TaskRepositoryImpl(database.taskDao);
    categoryRepository = CategoryRepositoryImpl(database.categoryDao);
    categoryId = await categoryRepository.create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
  });

  tearDown(() => database.close());

  test('create persists a task with default pending status', () async {
    final id = await repository.create(title: 'Write report', categoryId: categoryId);

    final tasks = await repository.watchAll().first;

    expect(tasks, hasLength(1));
    expect(tasks.single.id, id);
    expect(tasks.single.title, 'Write report');
    expect(tasks.single.status, TaskStatus.pending);
    expect(tasks.single.categoryId, categoryId);
  });

  test('setStatus marks a task completed and stamps completedAt', () async {
    final id = await repository.create(title: 'Read book', categoryId: categoryId);

    await repository.setStatus(id, TaskStatus.completed);

    final task = await repository.getById(id);
    expect(task!.status, TaskStatus.completed);
    expect(task.completedAt, isNotNull);
  });

  test('setStatus back to pending clears completedAt', () async {
    final id = await repository.create(title: 'Read book', categoryId: categoryId);
    await repository.setStatus(id, TaskStatus.completed);

    await repository.setStatus(id, TaskStatus.pending);

    final task = await repository.getById(id);
    expect(task!.status, TaskStatus.pending);
    expect(task.completedAt, isNull);
  });

  test('watchAll(includeCompleted: false) excludes completed tasks', () async {
    final pendingId = await repository.create(title: 'Pending', categoryId: categoryId);
    final doneId = await repository.create(title: 'Done', categoryId: categoryId);
    await repository.setStatus(doneId, TaskStatus.completed);

    final active = await repository.watchAll(includeCompleted: false).first;

    expect(active.map((t) => t.id), [pendingId]);
  });

  test('update persists changed fields', () async {
    final id = await repository.create(title: 'Draft', categoryId: categoryId);
    final task = await repository.getById(id);

    await repository.update(
      task!.copyWith(title: 'Final', description: 'Reviewed'),
    );

    final updated = await repository.getById(id);
    expect(updated!.title, 'Final');
    expect(updated.description, 'Reviewed');
  });

  test('watchAll filters by categoryId', () async {
    final otherCategoryId = await categoryRepository.create(
      name: 'Study',
      colorValue: 0xFF000000,
      iconKey: 'study',
    );
    await repository.create(title: 'Work task', categoryId: categoryId);
    await repository.create(title: 'Study task', categoryId: otherCategoryId);

    final workTasks = await repository.watchAll(categoryId: categoryId).first;

    expect(workTasks, hasLength(1));
    expect(workTasks.single.title, 'Work task');
  });

  test('delete removes the task', () async {
    final id = await repository.create(title: 'Temp', categoryId: categoryId);

    await repository.delete(id);

    final task = await repository.getById(id);
    expect(task, isNull);
  });

  test('getById returns null for an unknown id', () async {
    final result = await repository.getById(999);
    expect(result, isNull);
  });
}
