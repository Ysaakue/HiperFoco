import '../entities/occurrence_status.dart';
import '../entities/task_occurrence_override.dart';

abstract interface class TaskOccurrenceOverrideRepository {
  Stream<List<TaskOccurrenceOverride>> watchForTaskBetween(
    int taskId,
    DateTime start,
    DateTime end,
  );

  Stream<List<TaskOccurrenceOverride>> watchAllBetween(
    DateTime start,
    DateTime end,
  );

  Future<void> setStatus(
    int taskId,
    DateTime occurrenceDate,
    OccurrenceStatus status, {
    DateTime? rescheduledTo,
  });

  Future<void> clearOverride(int taskId, DateTime occurrenceDate);

  Future<void> deleteForTask(int taskId);
}
