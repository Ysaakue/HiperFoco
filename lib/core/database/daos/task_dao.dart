import 'package:drift/drift.dart';

import '../../../features/tasks/domain/entities/task_status.dart';
import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<TaskRow>> watchAll({int? categoryId, bool includeCompleted = true}) {
    final query = select(tasks)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (!includeCompleted) {
      query.where((t) => t.status.equalsValue(TaskStatus.completed).not());
    }
    return query.watch();
  }

  Future<TaskRow?> getById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTask(TasksCompanion entry) => into(tasks).insert(entry);

  Future<bool> updateTask(TasksCompanion entry) =>
      update(tasks).replace(entry);

  Future<int> setStatus(int id, TaskStatus status, {DateTime? completedAt}) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: Value(status),
          completedAt: Value(completedAt),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> deleteTask(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();
}
