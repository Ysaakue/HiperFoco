import '../entities/task.dart';
import '../entities/task_status.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchAll({int? categoryId, bool includeCompleted = true});

  Future<Task?> getById(int id);

  Future<int> create({
    required String title,
    String? description,
    required int categoryId,
    DateTime? dueDate,
  });

  Future<void> update(Task task);

  Future<void> setStatus(int id, TaskStatus status);

  Future<void> delete(int id);
}
