import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/reminder_dao.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._dao);

  final ReminderDao _dao;

  @override
  Stream<List<Reminder>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toEntity).toList());

  @override
  Stream<List<Reminder>> watchStandalone() =>
      _dao.watchStandalone().map((rows) => rows.map(_toEntity).toList());

  @override
  Stream<Reminder?> watchForTask(int taskId) {
    return _dao
        .watchForTask(taskId)
        .map((row) => row == null ? null : _toEntity(row));
  }

  @override
  Future<List<Reminder>> getAllEnabled() async {
    final rows = await _dao.getAllEnabled();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> create({
    int? taskId,
    int? recurrenceRuleId,
    DateTime? scheduledAt,
    int offsetMinutes = 0,
    String? message,
    bool isEnabled = true,
  }) {
    return _dao.insertReminder(
      RemindersCompanion.insert(
        taskId: Value(taskId),
        recurrenceRuleId: Value(recurrenceRuleId),
        scheduledAt: Value(scheduledAt),
        offsetMinutes: Value(offsetMinutes),
        message: Value(message),
        isEnabled: Value(isEnabled),
      ),
    );
  }

  @override
  Future<void> update(Reminder reminder) {
    return _dao.updateReminder(
      RemindersCompanion(
        id: Value(reminder.id),
        taskId: Value(reminder.taskId),
        recurrenceRuleId: Value(reminder.recurrenceRuleId),
        scheduledAt: Value(reminder.scheduledAt),
        offsetMinutes: Value(reminder.offsetMinutes),
        message: Value(reminder.message),
        isEnabled: Value(reminder.isEnabled),
        createdAt: Value(reminder.createdAt),
      ),
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteReminder(id);

  @override
  Future<void> deleteForTask(int taskId) => _dao.deleteForTask(taskId);

  Reminder _toEntity(ReminderRow row) {
    return Reminder(
      id: row.id,
      taskId: row.taskId,
      recurrenceRuleId: row.recurrenceRuleId,
      scheduledAt: row.scheduledAt,
      offsetMinutes: row.offsetMinutes,
      message: row.message,
      isEnabled: row.isEnabled,
      createdAt: row.createdAt,
    );
  }
}
