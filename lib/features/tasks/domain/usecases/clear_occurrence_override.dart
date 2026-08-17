import '../repositories/task_occurrence_override_repository.dart';

class ClearOccurrenceOverride {
  const ClearOccurrenceOverride(this._repository);

  final TaskOccurrenceOverrideRepository _repository;

  Future<void> call(int taskId, DateTime occurrenceDate) =>
      _repository.clearOverride(taskId, occurrenceDate);
}
