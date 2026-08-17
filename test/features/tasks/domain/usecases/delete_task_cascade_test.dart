import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/reminder_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_occurrence_override_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/occurrence_status.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/delete_task.dart';

/// End-to-end check (real Drift, no mocks) that deleting a task doesn't
/// leave orphaned rows behind — the database itself doesn't enforce the
/// taskId foreign keys on Reminders/TaskOccurrenceOverrides/GoalSteps
/// (Drift doesn't turn on `PRAGMA foreign_keys` by default), so nothing
/// would catch this at the schema level if DeleteTask stopped cleaning up
/// after itself.
void main() {
  test(
      'deleting a task also removes its reminder/overrides and unlinks any '
      'promoted goal step', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final taskRepository = TaskRepositoryImpl(database.taskDao);
    final reminderRepository = ReminderRepositoryImpl(database.reminderDao);
    final overrideRepository =
        TaskOccurrenceOverrideRepositoryImpl(database.taskOccurrenceOverrideDao);
    final goalRepository = GoalRepositoryImpl(database.goalDao);
    final goalStepRepository = GoalStepRepositoryImpl(database.goalStepDao);

    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final taskId =
        await taskRepository.create(title: 'Water plants', categoryId: categoryId);
    await reminderRepository.create(taskId: taskId);
    await overrideRepository.setStatus(
      taskId,
      DateTime(2026, 3, 2),
      OccurrenceStatus.done,
    );
    final goalId =
        await goalRepository.create(title: 'Keep the garden alive');
    final stepId =
        await goalStepRepository.create(goalId: goalId, title: 'Water plants');
    await goalStepRepository.setLinkedTask(stepId, taskId);

    await DeleteTask(
      taskRepository,
      reminderRepository,
      overrideRepository,
      goalStepRepository,
    )(taskId);

    expect(await taskRepository.getById(taskId), isNull);
    expect(await reminderRepository.watchForTask(taskId).first, isNull);
    expect(
      await overrideRepository
          .watchForTaskBetween(taskId, DateTime(2026, 1, 1), DateTime(2027, 1, 1))
          .first,
      isEmpty,
    );
    final steps = await goalStepRepository.watchForGoal(goalId).first;
    expect(steps.single.linkedTaskId, isNull);

    await database.close();
  });
}
