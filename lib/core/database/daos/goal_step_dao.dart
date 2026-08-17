import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/goal_steps_table.dart';

part 'goal_step_dao.g.dart';

@DriftAccessor(tables: [GoalSteps])
class GoalStepDao extends DatabaseAccessor<AppDatabase>
    with _$GoalStepDaoMixin {
  GoalStepDao(super.db);

  Stream<List<GoalStepRow>> watchForGoal(int goalId) {
    final query = select(goalSteps)
      ..where((t) => t.goalId.equals(goalId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  Future<int> countForGoal(int goalId) async {
    final rows = await (select(goalSteps)
          ..where((t) => t.goalId.equals(goalId)))
        .get();
    return rows.length;
  }

  Future<GoalStepRow?> getById(int id) =>
      (select(goalSteps)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertStep(GoalStepsCompanion entry) =>
      into(goalSteps).insert(entry);

  Future<int> setDone(int id, bool isDone) =>
      (update(goalSteps)..where((t) => t.id.equals(id)))
          .write(GoalStepsCompanion(isDone: Value(isDone)));

  Future<int> setLinkedTask(int id, int? taskId) =>
      (update(goalSteps)..where((t) => t.id.equals(id)))
          .write(GoalStepsCompanion(linkedTaskId: Value(taskId)));

  /// Called from `DeleteTask`'s cascade so a step whose promoted task was
  /// deleted goes back to looking "not promoted" instead of pointing at a
  /// task that no longer exists.
  Future<int> clearLinkedTask(int taskId) =>
      (update(goalSteps)..where((t) => t.linkedTaskId.equals(taskId)))
          .write(const GoalStepsCompanion(linkedTaskId: Value(null)));

  /// Called from `SetTaskStatus` so a step's checklist state mirrors its
  /// promoted task's completion — a no-op if no step links to [taskId].
  Future<int> setDoneForLinkedTask(int taskId, bool isDone) =>
      (update(goalSteps)..where((t) => t.linkedTaskId.equals(taskId)))
          .write(GoalStepsCompanion(isDone: Value(isDone)));

  Future<void> updateSortOrders(Map<int, int> sortOrderById) {
    return attachedDatabase.transaction(() async {
      for (final entry in sortOrderById.entries) {
        await (update(goalSteps)..where((t) => t.id.equals(entry.key)))
            .write(GoalStepsCompanion(sortOrder: Value(entry.value)));
      }
    });
  }

  Future<int> deleteStep(int id) =>
      (delete(goalSteps)..where((t) => t.id.equals(id))).go();

  Future<int> deleteForGoal(int goalId) =>
      (delete(goalSteps)..where((t) => t.goalId.equals(goalId))).go();
}
