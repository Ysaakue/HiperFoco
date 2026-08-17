import '../../../goals/domain/repositories/goal_step_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/task_occurrence_override_repository.dart';
import '../repositories/task_repository.dart';

/// Deleting a task doesn't cascade at the database level (tasks are the one
/// entity in this schema that can be hard-deleted, and foreign keys aren't
/// enforced), so this usecase cleans up its dependents itself: any linked
/// reminder, any recorded occurrence overrides, and any goal step that was
/// promoted to this task (unlinked back to "not promoted" rather than left
/// pointing at nothing) — before removing the task row.
class DeleteTask {
  const DeleteTask(
    this._taskRepository,
    this._reminderRepository,
    this._overrideRepository,
    this._goalStepRepository,
  );

  final TaskRepository _taskRepository;
  final ReminderRepository _reminderRepository;
  final TaskOccurrenceOverrideRepository _overrideRepository;
  final GoalStepRepository _goalStepRepository;

  Future<void> call(int id) async {
    await _reminderRepository.deleteForTask(id);
    await _overrideRepository.deleteForTask(id);
    await _goalStepRepository.clearLinkedTask(id);
    await _taskRepository.delete(id);
  }
}
