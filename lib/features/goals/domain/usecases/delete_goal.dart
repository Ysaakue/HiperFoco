import '../repositories/goal_repository.dart';
import '../repositories/goal_step_repository.dart';

/// Deletes a goal's steps before the goal itself — like `DeleteTask`, this
/// schema doesn't get foreign-key enforcement from Drift, so a hard-delete
/// entity has to clean up its own dependents or they survive as orphans.
class DeleteGoal {
  const DeleteGoal(this._goalRepository, this._stepRepository);

  final GoalRepository _goalRepository;
  final GoalStepRepository _stepRepository;

  Future<void> call(int id) async {
    await _stepRepository.deleteForGoal(id);
    await _goalRepository.delete(id);
  }
}
