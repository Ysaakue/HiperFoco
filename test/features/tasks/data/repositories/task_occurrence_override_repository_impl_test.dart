import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_occurrence_override_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/occurrence_status.dart';

void main() {
  late AppDatabase database;
  late TaskOccurrenceOverrideRepositoryImpl repository;
  late int taskId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TaskOccurrenceOverrideRepositoryImpl(
      database.taskOccurrenceOverrideDao,
    );
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    taskId = await TaskRepositoryImpl(database.taskDao)
        .create(title: 'Water plants', categoryId: categoryId);
  });

  tearDown(() => database.close());

  test('setStatus creates an override on first call', () async {
    await repository.setStatus(
      taskId,
      DateTime(2026, 3, 2),
      OccurrenceStatus.done,
    );

    final overrides = await repository
        .watchForTaskBetween(taskId, DateTime(2026, 3, 1), DateTime(2026, 3, 10))
        .first;

    expect(overrides, hasLength(1));
    expect(overrides.single.status, OccurrenceStatus.done);
    expect(overrides.single.rescheduledTo, isNull);
  });

  test('setStatus on the same occurrence again replaces the status instead of '
      'duplicating the row', () async {
    await repository.setStatus(taskId, DateTime(2026, 3, 2), OccurrenceStatus.done);
    await repository.setStatus(
      taskId,
      DateTime(2026, 3, 2),
      OccurrenceStatus.skipped,
    );

    final overrides = await repository
        .watchForTaskBetween(taskId, DateTime(2026, 3, 1), DateTime(2026, 3, 10))
        .first;

    expect(overrides, hasLength(1));
    expect(overrides.single.status, OccurrenceStatus.skipped);
  });

  test('rescheduledTo is stored alongside a rescheduled status', () async {
    await repository.setStatus(
      taskId,
      DateTime(2026, 3, 2),
      OccurrenceStatus.rescheduled,
      rescheduledTo: DateTime(2026, 3, 5),
    );

    final overrides = await repository
        .watchForTaskBetween(taskId, DateTime(2026, 3, 1), DateTime(2026, 3, 10))
        .first;

    expect(overrides.single.rescheduledTo, DateTime(2026, 3, 5));
  });

  test('clearOverride removes it entirely', () async {
    await repository.setStatus(taskId, DateTime(2026, 3, 2), OccurrenceStatus.done);

    await repository.clearOverride(taskId, DateTime(2026, 3, 2));

    final overrides = await repository
        .watchForTaskBetween(taskId, DateTime(2026, 3, 1), DateTime(2026, 3, 10))
        .first;
    expect(overrides, isEmpty);
  });

  test('deleteForTask removes every override for that task', () async {
    await repository.setStatus(taskId, DateTime(2026, 3, 2), OccurrenceStatus.done);
    await repository.setStatus(
      taskId,
      DateTime(2026, 3, 3),
      OccurrenceStatus.skipped,
    );

    await repository.deleteForTask(taskId);

    final overrides = await repository
        .watchForTaskBetween(taskId, DateTime(2026, 3, 1), DateTime(2026, 3, 10))
        .first;
    expect(overrides, isEmpty);
  });

  test('watchAllBetween only returns overrides inside the range', () async {
    await repository.setStatus(taskId, DateTime(2026, 3, 2), OccurrenceStatus.done);
    await repository.setStatus(
      taskId,
      DateTime(2026, 4, 2),
      OccurrenceStatus.done,
    );

    final overrides = await repository
        .watchAllBetween(DateTime(2026, 3, 1), DateTime(2026, 4, 1))
        .first;

    expect(overrides, hasLength(1));
    expect(overrides.single.occurrenceDate, DateTime(2026, 3, 2));
  });
}
