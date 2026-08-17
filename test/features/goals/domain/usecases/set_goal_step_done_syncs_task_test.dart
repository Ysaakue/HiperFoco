import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/goals/domain/usecases/set_goal_step_done.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';

/// End-to-end check (real Drift, no mocks) that checking/unchecking a
/// promoted goal step keeps its linked task's status in sync — the mirror
/// image of set_task_status_syncs_goal_step_test.dart, which covers the
/// task-drives-step direction.
void main() {
  test(
      'marking a promoted step done completes its linked task; unmarking it '
      'reopens the task', () async {
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
    final unlinkedStepId =
        await goalStepRepository.create(goalId: goalId, title: 'Read the docs');

    final setGoalStepDone = SetGoalStepDone(goalStepRepository, taskRepository);

    await setGoalStepDone(stepId, true);
    expect((await taskRepository.getById(taskId))!.status, TaskStatus.completed);

    await setGoalStepDone(stepId, false);
    expect((await taskRepository.getById(taskId))!.status, TaskStatus.pending);

    // Marking an unlinked step done must not touch any task.
    await setGoalStepDone(unlinkedStepId, true);
    expect((await taskRepository.getById(taskId))!.status, TaskStatus.pending);

    await database.close();
  });
}
