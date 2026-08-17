import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/set_task_status.dart';

/// End-to-end check (real Drift, no mocks) that completing/reopening a task
/// created by "promote step to task" keeps the originating goal step's
/// checklist state in sync, without touching steps that aren't linked to
/// this task.
void main() {
  test(
      'completing a promoted task marks its goal step done; reopening it '
      'clears that again, leaving other steps untouched', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final taskRepository = TaskRepositoryImpl(database.taskDao);
    final goalRepository = GoalRepositoryImpl(database.goalDao);
    final goalStepRepository = GoalStepRepositoryImpl(database.goalStepDao);

    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Studies',
      colorValue: 0xFF7C5CFC,
      iconKey: 'school',
    );
    final taskId = await taskRepository.create(
      title: 'Build an app',
      categoryId: categoryId,
    );
    final goalId = await goalRepository.create(title: 'Learn Flutter');
    final stepId =
        await goalStepRepository.create(goalId: goalId, title: 'Build an app');
    await goalStepRepository.setLinkedTask(stepId, taskId);
    final untouchedStepId =
        await goalStepRepository.create(goalId: goalId, title: 'Read the docs');

    final setTaskStatus = SetTaskStatus(taskRepository, goalStepRepository);

    await setTaskStatus(taskId, TaskStatus.completed);
    var steps = await goalStepRepository.watchForGoal(goalId).first;
    expect(steps.firstWhere((s) => s.id == stepId).isDone, isTrue);
    expect(steps.firstWhere((s) => s.id == untouchedStepId).isDone, isFalse);

    await setTaskStatus(taskId, TaskStatus.pending);
    steps = await goalStepRepository.watchForGoal(goalId).first;
    expect(steps.firstWhere((s) => s.id == stepId).isDone, isFalse);

    await database.close();
  });
}
