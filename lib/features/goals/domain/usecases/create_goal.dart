import '../repositories/goal_repository.dart';

class CreateGoal {
  const CreateGoal(this._repository);

  final GoalRepository _repository;

  Future<int> call({required String title, String? description}) {
    return _repository.create(title: title, description: description);
  }
}
