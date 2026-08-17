import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/goal_dao.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dao);

  final GoalDao _dao;

  @override
  Stream<List<Goal>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<Goal?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create({required String title, String? description}) {
    return _dao.insertGoal(
      GoalsCompanion.insert(title: title, description: Value(description)),
    );
  }

  @override
  Future<void> update(Goal goal) {
    return _dao.updateGoal(
      GoalsCompanion(
        id: Value(goal.id),
        title: Value(goal.title),
        description: Value(goal.description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteGoal(id);

  Goal _toEntity(GoalRow row) {
    return Goal(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
