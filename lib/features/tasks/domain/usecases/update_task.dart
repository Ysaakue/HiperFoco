import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<void> call(Task task) => _repository.update(task);
}
