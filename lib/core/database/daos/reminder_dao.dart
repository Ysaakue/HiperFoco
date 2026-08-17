import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reminders_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<ReminderRow>> watchAll() {
    return (select(reminders)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Standalone reminders only — not linked to any task.
  Stream<List<ReminderRow>> watchStandalone() {
    final query = select(reminders)
      ..where((t) => t.taskId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch();
  }

  Stream<ReminderRow?> watchForTask(int taskId) {
    return (select(reminders)..where((t) => t.taskId.equals(taskId)))
        .watchSingleOrNull();
  }

  Future<List<ReminderRow>> getAllEnabled() =>
      (select(reminders)..where((t) => t.isEnabled.equals(true))).get();

  Future<int> insertReminder(RemindersCompanion entry) =>
      into(reminders).insert(entry);

  Future<bool> updateReminder(RemindersCompanion entry) =>
      update(reminders).replace(entry);

  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();

  Future<int> deleteForTask(int taskId) =>
      (delete(reminders)..where((t) => t.taskId.equals(taskId))).go();
}
