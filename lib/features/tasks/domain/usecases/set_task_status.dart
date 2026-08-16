import '../entities/task_status.dart';
import '../repositories/task_repository.dart';

class SetTaskStatus {
  const SetTaskStatus(this._repository);

  final TaskRepository _repository;

  Future<void> call(int id, TaskStatus status) =>
      _repository.setStatus(id, status);
}
