import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/goal_step_dao.dart';
import '../../domain/entities/goal_step.dart';
import '../../domain/repositories/goal_step_repository.dart';

class GoalStepRepositoryImpl implements GoalStepRepository {
  GoalStepRepositoryImpl(this._dao);

  final GoalStepDao _dao;

  @override
  Stream<List<GoalStep>> watchForGoal(int goalId) {
    return _dao.watchForGoal(goalId).map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<int> create({required int goalId, required String title}) async {
    final sortOrder = await _dao.countForGoal(goalId);
    return _dao.insertStep(
      GoalStepsCompanion.insert(
        goalId: goalId,
        title: title,
        sortOrder: Value(sortOrder),
      ),
    );
  }

  @override
  Future<GoalStep?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> setDone(int id, bool isDone) => _dao.setDone(id, isDone);

  @override
  Future<void> setLinkedTask(int id, int? taskId) =>
      _dao.setLinkedTask(id, taskId);

  @override
  Future<void> clearLinkedTask(int taskId) => _dao.clearLinkedTask(taskId);

  @override
  Future<void> setDoneForLinkedTask(int taskId, bool isDone) =>
      _dao.setDoneForLinkedTask(taskId, isDone);

  @override
  Future<void> reorder(List<int> orderedStepIds) {
    final sortOrderById = {
      for (var i = 0; i < orderedStepIds.length; i++) orderedStepIds[i]: i,
    };
    return _dao.updateSortOrders(sortOrderById);
  }

  @override
  Future<void> delete(int id) => _dao.deleteStep(id);

  @override
  Future<void> deleteForGoal(int goalId) => _dao.deleteForGoal(goalId);

  GoalStep _toEntity(GoalStepRow row) {
    return GoalStep(
      id: row.id,
      goalId: row.goalId,
      title: row.title,
      isDone: row.isDone,
      sortOrder: row.sortOrder,
      linkedTaskId: row.linkedTaskId,
      createdAt: row.createdAt,
    );
  }
}
