import 'package:drift/drift.dart';

import '../../../features/tasks/domain/entities/occurrence_status.dart';
import '../app_database.dart';
import '../tables/task_occurrence_overrides_table.dart';

part 'task_occurrence_override_dao.g.dart';

@DriftAccessor(tables: [TaskOccurrenceOverrides])
class TaskOccurrenceOverrideDao extends DatabaseAccessor<AppDatabase>
    with _$TaskOccurrenceOverrideDaoMixin {
  TaskOccurrenceOverrideDao(super.db);

  Stream<List<TaskOccurrenceOverrideRow>> watchForTaskBetween(
    int taskId,
    DateTime start,
    DateTime end,
  ) {
    final query = select(taskOccurrenceOverrides)
      ..where(
        (t) =>
            t.taskId.equals(taskId) &
            t.occurrenceDate.isBiggerOrEqualValue(start) &
            t.occurrenceDate.isSmallerThanValue(end),
      );
    return query.watch();
  }

  Stream<List<TaskOccurrenceOverrideRow>> watchAllBetween(
    DateTime start,
    DateTime end,
  ) {
    final query = select(taskOccurrenceOverrides)
      ..where(
        (t) =>
            t.occurrenceDate.isBiggerOrEqualValue(start) &
            t.occurrenceDate.isSmallerThanValue(end),
      );
    return query.watch();
  }

  Future<TaskOccurrenceOverrideRow?> _findExisting(
    int taskId,
    DateTime occurrenceDate,
  ) {
    return (select(taskOccurrenceOverrides)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.occurrenceDate.equals(occurrenceDate),
          ))
        .getSingleOrNull();
  }

  /// Upserts the override for a single occurrence: creates it if this is the
  /// first exception recorded for (taskId, occurrenceDate), otherwise
  /// replaces its status in place.
  Future<void> setStatus(
    int taskId,
    DateTime occurrenceDate,
    OccurrenceStatus status, {
    DateTime? rescheduledTo,
  }) async {
    final existing = await _findExisting(taskId, occurrenceDate);
    if (existing == null) {
      await into(taskOccurrenceOverrides).insert(
        TaskOccurrenceOverridesCompanion.insert(
          taskId: taskId,
          occurrenceDate: occurrenceDate,
          status: status,
          rescheduledTo: Value(rescheduledTo),
        ),
      );
    } else {
      await (update(taskOccurrenceOverrides)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        TaskOccurrenceOverridesCompanion(
          status: Value(status),
          rescheduledTo: Value(rescheduledTo),
        ),
      );
    }
  }

  Future<int> clearOverride(int taskId, DateTime occurrenceDate) =>
      (delete(taskOccurrenceOverrides)
            ..where(
              (t) =>
                  t.taskId.equals(taskId) &
                  t.occurrenceDate.equals(occurrenceDate),
            ))
          .go();

  Future<int> deleteForTask(int taskId) => (delete(taskOccurrenceOverrides)
        ..where((t) => t.taskId.equals(taskId)))
      .go();
}
