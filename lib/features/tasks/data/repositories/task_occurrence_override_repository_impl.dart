import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/task_occurrence_override_dao.dart';
import '../../domain/entities/occurrence_status.dart';
import '../../domain/entities/task_occurrence_override.dart';
import '../../domain/repositories/task_occurrence_override_repository.dart';

class TaskOccurrenceOverrideRepositoryImpl
    implements TaskOccurrenceOverrideRepository {
  TaskOccurrenceOverrideRepositoryImpl(this._dao);

  final TaskOccurrenceOverrideDao _dao;

  @override
  Stream<List<TaskOccurrenceOverride>> watchForTaskBetween(
    int taskId,
    DateTime start,
    DateTime end,
  ) {
    return _dao
        .watchForTaskBetween(taskId, start, end)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Stream<List<TaskOccurrenceOverride>> watchAllBetween(
    DateTime start,
    DateTime end,
  ) {
    return _dao
        .watchAllBetween(start, end)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> setStatus(
    int taskId,
    DateTime occurrenceDate,
    OccurrenceStatus status, {
    DateTime? rescheduledTo,
  }) {
    return _dao.setStatus(
      taskId,
      occurrenceDate,
      status,
      rescheduledTo: rescheduledTo,
    );
  }

  @override
  Future<void> clearOverride(int taskId, DateTime occurrenceDate) =>
      _dao.clearOverride(taskId, occurrenceDate);

  @override
  Future<void> deleteForTask(int taskId) => _dao.deleteForTask(taskId);

  TaskOccurrenceOverride _toEntity(TaskOccurrenceOverrideRow row) {
    return TaskOccurrenceOverride(
      id: row.id,
      taskId: row.taskId,
      occurrenceDate: row.occurrenceDate,
      status: row.status,
      rescheduledTo: row.rescheduledTo,
    );
  }
}
