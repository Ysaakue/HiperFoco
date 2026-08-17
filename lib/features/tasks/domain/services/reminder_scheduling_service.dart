import 'package:clock/clock.dart';

import '../entities/recurrence_rule.dart';
import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';
import '../repositories/recurrence_rule_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/task_repository.dart';
import 'recurrence_engine.dart';

/// Runs at boot (and whenever a reminder/task/recurrence rule changes):
/// resyncs every enabled reminder's *next* scheduled notification.
///
/// Recurring reminders only ever have their single next occurrence
/// scheduled — the following one is picked up the next time this runs. That
/// always happens on the next app boot, so a reminder never goes more than
/// one fire-and-reopen cycle unscheduled, matching this app's "no
/// second-level precision needed" reminder philosophy.
class ReminderSchedulingService {
  const ReminderSchedulingService(
    this._reminderRepository,
    this._taskRepository,
    this._recurrenceRuleRepository,
    this._scheduler, [
    this._engine = const RecurrenceEngine(),
  ]);

  final ReminderRepository _reminderRepository;
  final TaskRepository _taskRepository;
  final RecurrenceRuleRepository _recurrenceRuleRepository;
  final NotificationScheduler _scheduler;
  final RecurrenceEngine _engine;

  /// How far ahead to search for a recurring rule's next occurrence before
  /// giving up — generous enough for any daily/weekly/monthly rule with a
  /// reasonable interval, without scanning indefinitely for one that will
  /// never produce another occurrence (e.g. already past its end date).
  static const _searchWindow = Duration(days: 730);

  Future<void> run() async {
    await _scheduler.cancelAll();

    final now = clock.now();
    final reminders = await _reminderRepository.getAllEnabled();
    for (final reminder in reminders) {
      final fireAt = await _resolveNextFireTime(reminder, now);
      if (fireAt == null || !fireAt.isAfter(now)) continue;

      await _scheduler.schedule(
        id: reminder.id,
        title: await _resolveTitle(reminder),
        body: reminder.message,
        scheduledAt: fireAt,
      );
    }
  }

  Future<DateTime?> _resolveNextFireTime(Reminder reminder, DateTime now) async {
    final offset = Duration(minutes: reminder.offsetMinutes);

    if (reminder.taskId != null) {
      final task = await _taskRepository.getById(reminder.taskId!);
      if (task == null) return null;
      if (task.recurrenceRuleId != null) {
        final rule = await _recurrenceRuleRepository.getById(task.recurrenceRuleId!);
        final anchor = rule == null ? null : _nextOccurrenceAnchor(rule, now);
        return anchor?.subtract(offset);
      }
      return task.dueDate?.subtract(offset);
    }

    if (reminder.recurrenceRuleId != null) {
      final rule = await _recurrenceRuleRepository.getById(reminder.recurrenceRuleId!);
      final anchor = rule == null ? null : _nextOccurrenceAnchor(rule, now);
      return anchor?.subtract(offset);
    }

    return reminder.scheduledAt;
  }

  /// The next occurrence on/after [now]'s calendar day, with the rule's
  /// [RecurrenceRule.startDate] time-of-day re-applied to it.
  DateTime? _nextOccurrenceAnchor(RecurrenceRule rule, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dates =
        _engine.occurrencesBetween(rule, today, today.add(_searchWindow));
    if (dates.isEmpty) return null;
    final date = dates.first;
    return DateTime(
      date.year,
      date.month,
      date.day,
      rule.startDate.hour,
      rule.startDate.minute,
    );
  }

  Future<String> _resolveTitle(Reminder reminder) async {
    if (reminder.taskId != null) {
      final task = await _taskRepository.getById(reminder.taskId!);
      if (task != null) return task.title;
    }
    return reminder.message ?? 'Reminder';
  }
}
