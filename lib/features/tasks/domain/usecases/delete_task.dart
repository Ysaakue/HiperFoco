import '../repositories/reminder_repository.dart';
import '../repositories/task_occurrence_override_repository.dart';
import '../repositories/task_repository.dart';

/// Deleting a task doesn't cascade at the database level (tasks are the one
/// entity in this schema that can be hard-deleted, and foreign keys aren't
/// enforced), so this usecase cleans up its dependents itself: any linked
/// reminder and any recorded occurrence overrides, before removing the task
/// row — otherwise both would silently survive as orphaned rows forever.
class DeleteTask {
  const DeleteTask(
    this._taskRepository,
    this._reminderRepository,
    this._overrideRepository,
  );

  final TaskRepository _taskRepository;
  final ReminderRepository _reminderRepository;
  final TaskOccurrenceOverrideRepository _overrideRepository;

  Future<void> call(int id) async {
    await _reminderRepository.deleteForTask(id);
    await _overrideRepository.deleteForTask(id);
    await _taskRepository.delete(id);
  }
}
