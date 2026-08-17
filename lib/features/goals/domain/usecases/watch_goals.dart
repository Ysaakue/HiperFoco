import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class WatchGoals {
  const WatchGoals(this._repository);

  final GoalRepository _repository;

  Stream<List<Goal>> call() => _repository.watchAll();
}
