import '../entities/goal_step.dart';

abstract interface class GoalStepRepository {
  Stream<List<GoalStep>> watchForGoal(int goalId);

  /// Appends a new step to the end of the goal's list (sort order is
  /// computed internally from the current step count).
  Future<int> create({required int goalId, required String title});

  /// Returns the step, or null if it doesn't exist — used by
  /// `SetGoalStepDone` to check whether the step is linked to a task that
  /// also needs its status mirrored.
  Future<GoalStep?> getById(int id);

  Future<void> setDone(int id, bool isDone);

  Future<void> setLinkedTask(int id, int? taskId);

  /// Unlinks any step currently pointing at [taskId] — used by `DeleteTask`
  /// so a promoted step doesn't keep pointing at a deleted task.
  Future<void> clearLinkedTask(int taskId);

  /// Mirrors [isDone] onto any step currently pointing at [taskId] — used by
  /// `SetTaskStatus` so completing/reopening a promoted task keeps its step
  /// in sync. A no-op if no step links to [taskId].
  Future<void> setDoneForLinkedTask(int taskId, bool isDone);

  /// Persists a full reorder: [orderedStepIds] is every step id for the
  /// goal, in its new display order.
  Future<void> reorder(List<int> orderedStepIds);

  Future<void> delete(int id);

  Future<void> deleteForGoal(int goalId);
}
