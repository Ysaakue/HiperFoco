import '../entities/task_occurrence_override.dart';
import '../repositories/task_occurrence_override_repository.dart';

class WatchOccurrenceOverridesBetween {
  const WatchOccurrenceOverridesBetween(this._repository);

  final TaskOccurrenceOverrideRepository _repository;

  Stream<List<TaskOccurrenceOverride>> call(DateTime start, DateTime end) =>
      _repository.watchAllBetween(start, end);
}
