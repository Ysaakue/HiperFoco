import '../repositories/goal_step_repository.dart';

class DeleteGoalStep {
  const DeleteGoalStep(this._repository);

  final GoalStepRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
