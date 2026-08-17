import '../repositories/goal_step_repository.dart';

class CreateGoalStep {
  const CreateGoalStep(this._repository);

  final GoalStepRepository _repository;

  Future<int> call({required int goalId, required String title}) {
    return _repository.create(goalId: goalId, title: title);
  }
}
