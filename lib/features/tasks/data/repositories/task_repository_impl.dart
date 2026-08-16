import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/task_dao.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dao);

  final TaskDao _dao;

  @override
  Stream<List<Task>> watchAll({int? categoryId, bool includeCompleted = true}) {
    return _dao
        .watchAll(categoryId: categoryId, includeCompleted: includeCompleted)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Task?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create({
    required String title,
    String? description,
    required int categoryId,
    DateTime? dueDate,
  }) {
    return _dao.insertTask(
      TasksCompanion.insert(
        title: title,
        description: Value(description),
        categoryId: categoryId,
        dueDate: Value(dueDate),
      ),
    );
  }

  @override
  Future<void> update(Task task) {
    return _dao.updateTask(
      TasksCompanion(
        id: Value(task.id),
        title: Value(task.title),
        description: Value(task.description),
        categoryId: Value(task.categoryId),
        status: Value(task.status),
        dueDate: Value(task.dueDate),
        sortOrder: Value(task.sortOrder),
        updatedAt: Value(DateTime.now()),
        completedAt: Value(task.completedAt),
      ),
    );
  }

  @override
  Future<void> setStatus(int id, TaskStatus status) {
    return _dao.setStatus(
      id,
      status,
      completedAt: status == TaskStatus.completed ? DateTime.now() : null,
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteTask(id);

  Task _toEntity(TaskRow row) {
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      categoryId: row.categoryId,
      status: row.status,
      dueDate: row.dueDate,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }
}
