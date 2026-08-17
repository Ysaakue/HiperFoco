import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';

void main() {
  Task task() {
    return Task(
      id: 1,
      title: 'Write report',
      description: 'Quarterly numbers',
      categoryId: 10,
      status: TaskStatus.pending,
      dueDate: DateTime(2026, 3, 15),
      recurrenceRuleId: 7,
      sortOrder: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      completedAt: DateTime(2026, 1, 2),
    );
  }

  group('copyWith', () {
    test('omitting a nullable field keeps its current value', () {
      final updated = task().copyWith(title: 'New title');

      expect(updated.description, 'Quarterly numbers');
      expect(updated.dueDate, DateTime(2026, 3, 15));
      expect(updated.recurrenceRuleId, 7);
      expect(updated.completedAt, DateTime(2026, 1, 2));
    });

    test('explicitly passing null clears a nullable field', () {
      final updated = task().copyWith(
        description: null,
        dueDate: null,
        recurrenceRuleId: null,
        completedAt: null,
      );

      expect(updated.description, isNull);
      expect(updated.dueDate, isNull);
      expect(updated.recurrenceRuleId, isNull);
      expect(updated.completedAt, isNull);
    });

    test('passing a new value replaces the old one', () {
      final updated = task().copyWith(
        description: 'Revised',
        dueDate: DateTime(2026, 4, 1),
        recurrenceRuleId: 9,
      );

      expect(updated.description, 'Revised');
      expect(updated.dueDate, DateTime(2026, 4, 1));
      expect(updated.recurrenceRuleId, 9);
    });

    test('id and createdAt are never changed by copyWith', () {
      final updated = task().copyWith(title: 'New title');

      expect(updated.id, 1);
      expect(updated.createdAt, DateTime(2026, 1, 1));
    });
  });

  group('isRecurring', () {
    test('true when recurrenceRuleId is set', () {
      expect(task().isRecurring, isTrue);
    });

    test('false when recurrenceRuleId is null', () {
      expect(task().copyWith(recurrenceRuleId: null).isRecurring, isFalse);
    });
  });
}
