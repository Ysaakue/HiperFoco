import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/occurrence_status.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/entities/reminder.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_occurrence_override.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/recurrence_rule_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/reminder_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/task_occurrence_override_repository.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/clear_occurrence_override.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/create_recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/create_reminder.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/delete_recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/delete_reminder.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/get_recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/set_occurrence_status.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/update_recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/update_reminder.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/watch_occurrence_overrides_between.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/watch_reminder_for_task.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/watch_reminders.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/watch_standalone_reminders.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrenceRuleRepository extends Mock
    implements RecurrenceRuleRepository {}

class MockTaskOccurrenceOverrideRepository extends Mock
    implements TaskOccurrenceOverrideRepository {}

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  final rule = RecurrenceRule(
    id: 1,
    frequency: RecurrenceFrequency.weekly,
    interval: 1,
    byWeekdays: const [1, 3],
    startDate: DateTime(2026, 3, 2),
  );

  final override = TaskOccurrenceOverride(
    id: 1,
    taskId: 5,
    occurrenceDate: DateTime(2026, 3, 2),
    status: OccurrenceStatus.done,
  );

  final reminder = Reminder(
    id: 1,
    taskId: 5,
    offsetMinutes: 0,
    isEnabled: true,
    createdAt: DateTime(2026, 1, 1),
  );

  group('RecurrenceRule usecases', () {
    late MockRecurrenceRuleRepository repository;

    setUp(() => repository = MockRecurrenceRuleRepository());

    test('CreateRecurrenceRule delegates to repository.create', () async {
      when(() => repository.create(
            frequency: RecurrenceFrequency.weekly,
            interval: 1,
            byWeekdays: [1, 3],
            byMonthDay: null,
            startDate: DateTime(2026, 3, 2),
            endDate: null,
          )).thenAnswer((_) async => 1);

      final id = await CreateRecurrenceRule(repository)(
        frequency: RecurrenceFrequency.weekly,
        byWeekdays: [1, 3],
        startDate: DateTime(2026, 3, 2),
      );

      expect(id, 1);
    });

    test('UpdateRecurrenceRule delegates to repository.update', () async {
      when(() => repository.update(rule)).thenAnswer((_) async {});

      await UpdateRecurrenceRule(repository)(rule);

      verify(() => repository.update(rule)).called(1);
    });

    test('DeleteRecurrenceRule delegates to repository.delete', () async {
      when(() => repository.delete(1)).thenAnswer((_) async {});

      await DeleteRecurrenceRule(repository)(1);

      verify(() => repository.delete(1)).called(1);
    });

    test('GetRecurrenceRule delegates to repository.getById', () async {
      when(() => repository.getById(1)).thenAnswer((_) async => rule);

      final result = await GetRecurrenceRule(repository)(1);

      expect(result, rule);
    });
  });

  group('TaskOccurrenceOverride usecases', () {
    late MockTaskOccurrenceOverrideRepository repository;

    setUp(() => repository = MockTaskOccurrenceOverrideRepository());

    test('SetOccurrenceStatus delegates to repository.setStatus', () async {
      when(() => repository.setStatus(
            5,
            DateTime(2026, 3, 2),
            OccurrenceStatus.skipped,
            rescheduledTo: null,
          )).thenAnswer((_) async {});

      await SetOccurrenceStatus(repository)(
        5,
        DateTime(2026, 3, 2),
        OccurrenceStatus.skipped,
      );

      verify(() => repository.setStatus(
            5,
            DateTime(2026, 3, 2),
            OccurrenceStatus.skipped,
            rescheduledTo: null,
          )).called(1);
    });

    test('ClearOccurrenceOverride delegates to repository.clearOverride',
        () async {
      when(() => repository.clearOverride(5, DateTime(2026, 3, 2)))
          .thenAnswer((_) async {});

      await ClearOccurrenceOverride(repository)(5, DateTime(2026, 3, 2));

      verify(() => repository.clearOverride(5, DateTime(2026, 3, 2))).called(1);
    });

    test('WatchOccurrenceOverridesBetween delegates to repository.watchAllBetween',
        () {
      when(() => repository.watchAllBetween(DateTime(2026, 3, 1), DateTime(2026, 4, 1)))
          .thenAnswer((_) => Stream.value([override]));

      final stream = WatchOccurrenceOverridesBetween(repository)(
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(stream, emits([override]));
    });
  });

  group('Reminder usecases', () {
    late MockReminderRepository repository;

    setUp(() => repository = MockReminderRepository());

    test('CreateReminder delegates to repository.create', () async {
      when(() => repository.create(
            taskId: 5,
            recurrenceRuleId: null,
            scheduledAt: null,
            offsetMinutes: 15,
            message: null,
            isEnabled: true,
          )).thenAnswer((_) async => 1);

      final id = await CreateReminder(repository)(taskId: 5, offsetMinutes: 15);

      expect(id, 1);
    });

    test('UpdateReminder delegates to repository.update', () async {
      when(() => repository.update(reminder)).thenAnswer((_) async {});

      await UpdateReminder(repository)(reminder);

      verify(() => repository.update(reminder)).called(1);
    });

    test('DeleteReminder delegates to repository.delete', () async {
      when(() => repository.delete(1)).thenAnswer((_) async {});

      await DeleteReminder(repository)(1);

      verify(() => repository.delete(1)).called(1);
    });

    test('WatchReminders delegates to repository.watchAll', () {
      when(() => repository.watchAll()).thenAnswer((_) => Stream.value([reminder]));

      expect(WatchReminders(repository)(), emits([reminder]));
    });

    test('WatchStandaloneReminders delegates to repository.watchStandalone', () {
      when(() => repository.watchStandalone())
          .thenAnswer((_) => Stream.value([reminder]));

      expect(WatchStandaloneReminders(repository)(), emits([reminder]));
    });

    test('WatchReminderForTask delegates to repository.watchForTask', () {
      when(() => repository.watchForTask(5)).thenAnswer((_) => Stream.value(reminder));

      expect(WatchReminderForTask(repository)(5), emits(reminder));
    });
  });
}
