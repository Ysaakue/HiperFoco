import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/occurrence_status.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_occurrence_override.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/services/task_occurrence_calculator.dart';

void main() {
  const calculator = TaskOccurrenceCalculator();

  Task task({
    required int id,
    String title = 'Task',
    int? recurrenceRuleId,
    DateTime? dueDate,
    TaskStatus status = TaskStatus.pending,
  }) {
    return Task(
      id: id,
      title: title,
      categoryId: 1,
      status: status,
      dueDate: dueDate,
      recurrenceRuleId: recurrenceRuleId,
      sortOrder: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  group('non-recurring tasks', () {
    test('a due date inside the range becomes a single occurrence', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, dueDate: DateTime(2026, 3, 10))],
        rulesById: const {},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 4, 1),
      );

      expect(occurrences, hasLength(1));
      expect(occurrences.single.date, DateTime(2026, 3, 10));
      expect(occurrences.single.status, isNull);
    });

    test('a due date outside the range produces nothing', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, dueDate: DateTime(2026, 5, 1))],
        rulesById: const {},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 4, 1),
      );

      expect(occurrences, isEmpty);
    });

    test('no due date at all produces nothing', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1)],
        rulesById: const {},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 4, 1),
      );

      expect(occurrences, isEmpty);
    });

    test('a completed task\'s occurrence reports status done', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [
          task(
            id: 1,
            dueDate: DateTime(2026, 3, 10),
            status: TaskStatus.completed,
          ),
        ],
        rulesById: const {},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 4, 1),
      );

      expect(occurrences.single.status, OccurrenceStatus.done);
    });
  });

  group('recurring tasks', () {
    final rule = RecurrenceRule(
      id: 99,
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: DateTime(2026, 3, 1),
    );

    test('expands into one occurrence per date the engine produces', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, recurrenceRuleId: 99)],
        rulesById: {99: rule},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 4),
      );

      expect(
        occurrences.map((o) => o.date),
        [DateTime(2026, 3, 1), DateTime(2026, 3, 2), DateTime(2026, 3, 3)],
      );
      expect(occurrences.every((o) => o.status == null), isTrue);
    });

    test('a missing rule (deleted/orphaned) yields no occurrences instead of throwing', () {
      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, recurrenceRuleId: 404)],
        rulesById: const {},
        overrides: const [],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 4),
      );

      expect(occurrences, isEmpty);
    });

    test('an override only affects its own occurrence date, not the others', () {
      final overrides = [
        TaskOccurrenceOverride(
          id: 1,
          taskId: 1,
          occurrenceDate: DateTime(2026, 3, 2),
          status: OccurrenceStatus.done,
        ),
      ];

      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, recurrenceRuleId: 99)],
        rulesById: {99: rule},
        overrides: overrides,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 4),
      );

      final byDate = {for (final o in occurrences) o.date: o.status};
      expect(byDate[DateTime(2026, 3, 1)], isNull);
      expect(byDate[DateTime(2026, 3, 2)], OccurrenceStatus.done);
      expect(byDate[DateTime(2026, 3, 3)], isNull);
    });

    test('an override for a different task does not leak across tasks', () {
      final overrides = [
        TaskOccurrenceOverride(
          id: 1,
          taskId: 2,
          occurrenceDate: DateTime(2026, 3, 1),
          status: OccurrenceStatus.skipped,
        ),
      ];

      final occurrences = calculator.occurrencesBetween(
        tasks: [task(id: 1, recurrenceRuleId: 99)],
        rulesById: {99: rule},
        overrides: overrides,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      );

      expect(occurrences.single.status, isNull);
    });
  });

  test('results are sorted by date across multiple tasks', () {
    final rule = RecurrenceRule(
      id: 1,
      frequency: RecurrenceFrequency.daily,
      interval: 5,
      startDate: DateTime(2026, 3, 1),
    );

    final occurrences = calculator.occurrencesBetween(
      tasks: [
        task(id: 1, dueDate: DateTime(2026, 3, 3)),
        task(id: 2, recurrenceRuleId: 1),
      ],
      rulesById: {1: rule},
      overrides: const [],
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 10),
    );

    expect(
      occurrences.map((o) => o.date),
      [DateTime(2026, 3, 1), DateTime(2026, 3, 3), DateTime(2026, 3, 6)],
    );
  });
}
