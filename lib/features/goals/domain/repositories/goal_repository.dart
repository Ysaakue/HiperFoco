import '../entities/goal.dart';

abstract interface class GoalRepository {
  Stream<List<Goal>> watchAll();

  Future<Goal?> getById(int id);

  Future<int> create({required String title, String? description});

  Future<void> update(Goal goal);

  Future<void> delete(int id);
}
