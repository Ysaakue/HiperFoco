import 'package:drift/drift.dart';

import 'recurrence_rules_table.dart';
import 'tasks_table.dart';

/// A reminder has exactly one of three shapes:
/// - standalone single: [scheduledAt] set, [taskId] and [recurrenceRuleId] null
/// - standalone recurring: [recurrenceRuleId] set, the other two null
/// - task-linked: [taskId] set, inheriting its schedule (and recurrence, if
///   any) from that task's due date instead of carrying its own
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().nullable().references(Tasks, #id)();

  IntColumn get recurrenceRuleId =>
      integer().nullable().references(RecurrenceRules, #id)();

  DateTimeColumn get scheduledAt => dateTime().nullable()();

  /// Minutes before the anchor time (task due date, or a recurring
  /// occurrence's date) to actually fire. Not used for standalone
  /// [scheduledAt] reminders, which always fire exactly at that instant.
  IntColumn get offsetMinutes => integer().withDefault(const Constant(0))();

  TextColumn get message => text().nullable()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
