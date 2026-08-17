import '../entities/occurrence_status.dart';
import '../repositories/task_occurrence_override_repository.dart';

class SetOccurrenceStatus {
  const SetOccurrenceStatus(this._repository);

  final TaskOccurrenceOverrideRepository _repository;

  Future<void> call(
    int taskId,
    DateTime occurrenceDate,
    OccurrenceStatus status, {
    DateTime? rescheduledTo,
  }) {
    return _repository.setStatus(
      taskId,
      occurrenceDate,
      status,
      rescheduledTo: rescheduledTo,
    );
  }
}
