import '../entities/occurrence_status.dart';
import '../entities/recurrence_rule.dart';
import '../entities/task.dart';
import '../entities/task_occurrence.dart';
import '../entities/task_occurrence_override.dart';
import 'recurrence_engine.dart';

/// Merges tasks, their recurrence rules, and any per-occurrence overrides
/// into the flat list a calendar view renders — pure computation over
/// already-fetched data, no repository/stream access of its own.
class TaskOccurrenceCalculator {
  const TaskOccurrenceCalculator([this._engine = const RecurrenceEngine()]);

  final RecurrenceEngine _engine;

  /// Occurrences within `[start, end)`. Non-recurring tasks contribute at
  /// most one occurrence (their due date, if it falls in range); recurring
  /// tasks contribute one per virtual occurrence the rule produces in
  /// range, with [TaskOccurrenceOverride.status] resolved where present.
  List<TaskOccurrence> occurrencesBetween({
    required List<Task> tasks,
    required Map<int, RecurrenceRule> rulesById,
    required List<TaskOccurrenceOverride> overrides,
    required DateTime start,
    required DateTime end,
  }) {
    final overridesByTask = <int, Map<DateTime, TaskOccurrenceOverride>>{};
    for (final override in overrides) {
      overridesByTask.putIfAbsent(override.taskId, () => {})[
          _dateOnly(override.occurrenceDate)] = override;
    }

    final result = <TaskOccurrence>[];
    for (final task in tasks) {
      final ruleId = task.recurrenceRuleId;
      if (ruleId == null) {
        final due = task.dueDate;
        if (due == null) continue;
        final date = _dateOnly(due);
        if (date.isBefore(start) || !date.isBefore(end)) continue;
        result.add(
          TaskOccurrence(
            task: task,
            date: date,
            status: task.isCompleted ? OccurrenceStatus.done : null,
          ),
        );
        continue;
      }

      final rule = rulesById[ruleId];
      if (rule == null) continue;
      final taskOverrides = overridesByTask[task.id] ?? const {};
      for (final date in _engine.occurrencesBetween(rule, start, end)) {
        result.add(
          TaskOccurrence(task: task, date: date, status: taskOverrides[date]?.status),
        );
      }
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
