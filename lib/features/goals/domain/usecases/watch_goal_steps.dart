import '../entities/goal_step.dart';
import '../repositories/goal_step_repository.dart';

class WatchGoalSteps {
  const WatchGoalSteps(this._repository);

  final GoalStepRepository _repository;

  Stream<List<GoalStep>> call(int goalId) => _repository.watchForGoal(goalId);
}
