import '../../../goals/domain/repositories/goal_step_repository.dart';
import '../entities/task_status.dart';
import '../repositories/task_repository.dart';

class SetTaskStatus {
  const SetTaskStatus(this._repository, this._goalStepRepository);

  final TaskRepository _repository;
  final GoalStepRepository _goalStepRepository;

  /// Also mirrors the new status onto any goal step promoted from this task,
  /// so its checklist entry stays in sync with the task it created.
  Future<void> call(int id, TaskStatus status) async {
    await _repository.setStatus(id, status);
    await _goalStepRepository.setDoneForLinkedTask(
      id,
      status == TaskStatus.completed,
    );
  }
}
