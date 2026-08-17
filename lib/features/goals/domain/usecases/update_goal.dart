import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class UpdateGoal {
  const UpdateGoal(this._repository);

  final GoalRepository _repository;

  Future<void> call(Goal goal) => _repository.update(goal);
}
