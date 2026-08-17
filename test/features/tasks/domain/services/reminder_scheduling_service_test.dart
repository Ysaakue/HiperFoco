import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/entities/reminder.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/notification_scheduler.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/recurrence_rule_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/reminder_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/task_repository.dart';
import 'package:hiperfoco/features/tasks/domain/services/reminder_scheduling_service.dart';
import 'package:mocktail/mocktail.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockRecurrenceRuleRepository extends Mock
    implements RecurrenceRuleRepository {}

class MockNotificationScheduler extends Mock implements NotificationScheduler {}

Reminder _reminder({
  required int id,
  int? taskId,
  int? recurrenceRuleId,
  DateTime? scheduledAt,
  int offsetMinutes = 0,
  String? message,
}) {
  return Reminder(
    id: id,
    taskId: taskId,
    recurrenceRuleId: recurrenceRuleId,
    scheduledAt: scheduledAt,
    offsetMinutes: offsetMinutes,
    message: message,
    isEnabled: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Task _task({
  required int id,
  String title = 'Task',
  int? recurrenceRuleId,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: title,
    categoryId: 1,
    status: TaskStatus.pending,
    dueDate: dueDate,
    recurrenceRuleId: recurrenceRuleId,
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockReminderRepository reminderRepository;
  late MockTaskRepository taskRepository;
  late MockRecurrenceRuleRepository recurrenceRuleRepository;
  late MockNotificationScheduler scheduler;
  late ReminderSchedulingService service;

  final now = DateTime(2026, 3, 10, 9);

  setUpAll(() {
    registerFallbackValue(now);
  });

  setUp(() {
    reminderRepository = MockReminderRepository();
    taskRepository = MockTaskRepository();
    recurrenceRuleRepository = MockRecurrenceRuleRepository();
    scheduler = MockNotificationScheduler();
    service = ReminderSchedulingService(
      reminderRepository,
      taskRepository,
      recurrenceRuleRepository,
      scheduler,
    );

    when(() => scheduler.cancelAll()).thenAnswer((_) async {});
    when(() => scheduler.schedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledAt: any(named: 'scheduledAt'),
        )).thenAnswer((_) async {});
  });

  test('always cancels every previously scheduled notification first', () async {
    when(() => reminderRepository.getAllEnabled()).thenAnswer((_) async => []);

    await withClock(Clock.fixed(now), service.run);

    verify(() => scheduler.cancelAll()).called(1);
  });

  test('standalone one-time reminder in the future is scheduled as-is', () async {
    final scheduledAt = now.add(const Duration(hours: 2));
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, scheduledAt: scheduledAt, message: 'Call mom')],
    );

    await withClock(Clock.fixed(now), service.run);

    verify(() => scheduler.schedule(
          id: 1,
          title: 'Call mom',
          body: 'Call mom',
          scheduledAt: scheduledAt,
        )).called(1);
  });

  test('standalone one-time reminder already in the past is not scheduled',
      () async {
    final scheduledAt = now.subtract(const Duration(hours: 2));
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, scheduledAt: scheduledAt)],
    );

    await withClock(Clock.fixed(now), service.run);

    verifyNever(() => scheduler.schedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledAt: any(named: 'scheduledAt'),
        ));
  });

  test('standalone one-time reminder falls back to a generic title with no message',
      () async {
    final scheduledAt = now.add(const Duration(hours: 2));
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, scheduledAt: scheduledAt)],
    );

    await withClock(Clock.fixed(now), service.run);

    verify(() => scheduler.schedule(
          id: 1,
          title: 'Reminder',
          body: null,
          scheduledAt: scheduledAt,
        )).called(1);
  });

  test('standalone recurring reminder schedules the next occurrence, offset applied',
      () async {
    final rule = RecurrenceRule(
      id: 5,
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: DateTime(2026, 3, 1, 14, 30),
    );
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async =>
          [_reminder(id: 1, recurrenceRuleId: 5, offsetMinutes: 30, message: 'Stretch')],
    );
    when(() => recurrenceRuleRepository.getById(5)).thenAnswer((_) async => rule);

    await withClock(Clock.fixed(now), service.run);

    // Next occurrence on/after 2026-03-10 at 14:30, minus the 30-minute offset.
    verify(() => scheduler.schedule(
          id: 1,
          title: 'Stretch',
          body: 'Stretch',
          scheduledAt: DateTime(2026, 3, 10, 14),
        )).called(1);
  });

  test('task-linked reminder on a non-recurring task uses the task\'s due date',
      () async {
    final dueDate = now.add(const Duration(days: 1));
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, taskId: 7, offsetMinutes: 60)],
    );
    when(() => taskRepository.getById(7)).thenAnswer(
      (_) async => _task(id: 7, title: 'Submit report', dueDate: dueDate),
    );

    await withClock(Clock.fixed(now), service.run);

    verify(() => scheduler.schedule(
          id: 1,
          title: 'Submit report',
          body: null,
          scheduledAt: dueDate.subtract(const Duration(hours: 1)),
        )).called(1);
  });

  test('task-linked reminder on a recurring task uses the recurrence rule\'s next occurrence',
      () async {
    final rule = RecurrenceRule(
      id: 9,
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      startDate: DateTime(2026, 3, 9, 8), // Monday 08:00
    );
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, taskId: 7)],
    );
    when(() => taskRepository.getById(7)).thenAnswer(
      (_) async => _task(id: 7, title: 'Water plants', recurrenceRuleId: 9),
    );
    when(() => recurrenceRuleRepository.getById(9)).thenAnswer((_) async => rule);

    await withClock(Clock.fixed(now), service.run);

    // now is Tuesday 2026-03-10; next weekly Monday occurrence is 2026-03-16.
    verify(() => scheduler.schedule(
          id: 1,
          title: 'Water plants',
          body: null,
          scheduledAt: DateTime(2026, 3, 16, 8),
        )).called(1);
  });

  test('task-linked reminder pointing at a deleted task is not scheduled', () async {
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, taskId: 404)],
    );
    when(() => taskRepository.getById(404)).thenAnswer((_) async => null);

    await withClock(Clock.fixed(now), service.run);

    verifyNever(() => scheduler.schedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledAt: any(named: 'scheduledAt'),
        ));
  });

  test('a task with no due date and no recurrence is not scheduled', () async {
    when(() => reminderRepository.getAllEnabled()).thenAnswer(
      (_) async => [_reminder(id: 1, taskId: 7)],
    );
    when(() => taskRepository.getById(7)).thenAnswer(
      (_) async => _task(id: 7),
    );

    await withClock(Clock.fixed(now), service.run);

    verifyNever(() => scheduler.schedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledAt: any(named: 'scheduledAt'),
        ));
  });
}
