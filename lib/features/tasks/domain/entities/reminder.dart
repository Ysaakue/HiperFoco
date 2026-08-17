import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    this.taskId,
    this.recurrenceRuleId,
    this.scheduledAt,
    required this.offsetMinutes,
    this.message,
    required this.isEnabled,
    required this.createdAt,
  });

  final int id;

  /// When set, this reminder is task-linked: its schedule is derived from
  /// that task's due date (and recurrence, if any) instead of the fields
  /// below.
  final int? taskId;

  /// When set (and [taskId] is null), this is a standalone recurring
  /// reminder, scheduled from this rule instead of a fixed instant.
  final int? recurrenceRuleId;

  /// When set (and both FKs above are null), this is a standalone one-time
  /// reminder firing at exactly this instant.
  final DateTime? scheduledAt;

  /// Minutes before the anchor time (task due date, or a recurring
  /// occurrence's date) to actually fire. Not used for standalone
  /// [scheduledAt] reminders, which always fire exactly at that instant.
  final int offsetMinutes;

  final String? message;
  final bool isEnabled;
  final DateTime createdAt;

  bool get isTaskLinked => taskId != null;
  bool get isRecurring => recurrenceRuleId != null;

  @override
  List<Object?> get props => [
        id,
        taskId,
        recurrenceRuleId,
        scheduledAt,
        offsetMinutes,
        message,
        isEnabled,
        createdAt,
      ];
}
