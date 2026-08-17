import '../repositories/goal_step_repository.dart';

class ReorderGoalSteps {
  const ReorderGoalSteps(this._repository);

  final GoalStepRepository _repository;

  Future<void> call(List<int> orderedStepIds) =>
      _repository.reorder(orderedStepIds);
}
