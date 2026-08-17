import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../repositories/goal_step_repository.dart';

class SetGoalStepDone {
  const SetGoalStepDone(this._repository, this._taskRepository);

  final GoalStepRepository _repository;
  final TaskRepository _taskRepository;

  /// Also mirrors [isDone] onto the step's linked task, if it was promoted
  /// to one, so the two stay in sync however either one is checked.
  Future<void> call(int id, bool isDone) async {
    final step = await _repository.getById(id);
    await _repository.setDone(id, isDone);
    final linkedTaskId = step?.linkedTaskId;
    if (linkedTaskId != null) {
      await _taskRepository.setStatus(
        linkedTaskId,
        isDone ? TaskStatus.completed : TaskStatus.pending,
      );
    }
  }
}
