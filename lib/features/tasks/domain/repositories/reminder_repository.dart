import '../entities/reminder.dart';

abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchAll();

  Stream<List<Reminder>> watchStandalone();

  Stream<Reminder?> watchForTask(int taskId);

  Future<List<Reminder>> getAllEnabled();

  Future<int> create({
    int? taskId,
    int? recurrenceRuleId,
    DateTime? scheduledAt,
    int offsetMinutes = 0,
    String? message,
    bool isEnabled = true,
  });

  Future<void> update(Reminder reminder);

  Future<void> delete(int id);

  Future<void> deleteForTask(int taskId);
}
