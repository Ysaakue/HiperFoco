import '../entities/task.dart';
import '../repositories/task_repository.dart';

class WatchTasks {
  const WatchTasks(this._repository);

  final TaskRepository _repository;

  Stream<List<Task>> call({int? categoryId, bool includeCompleted = true}) {
    return _repository.watchAll(
      categoryId: categoryId,
      includeCompleted: includeCompleted,
    );
  }
}
