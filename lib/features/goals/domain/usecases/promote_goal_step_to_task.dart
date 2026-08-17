import '../../../tasks/domain/repositories/task_repository.dart';
import '../repositories/goal_step_repository.dart';

/// Creates a plain (non-recurring, no due date) task from a goal step's
/// title and links the two, so the step can show it's been promoted and
/// avoid being promoted twice. Further scheduling details (due date,
/// recurrence, reminder) are left for the user to add by editing the new
/// task normally — keeping the promotion flow itself a single tap.
class PromoteGoalStepToTask {
  const PromoteGoalStepToTask(this._stepRepository, this._taskRepository);

  final GoalStepRepository _stepRepository;
  final TaskRepository _taskRepository;

  Future<int> call({
    required int stepId,
    required String title,
    required int categoryId,
  }) async {
    final taskId =
        await _taskRepository.create(title: title, categoryId: categoryId);
    await _stepRepository.setLinkedTask(stepId, taskId);
    return taskId;
  }
}
