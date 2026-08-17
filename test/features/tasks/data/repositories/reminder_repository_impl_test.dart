import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/reminder_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/reminder.dart';

void main() {
  late AppDatabase database;
  late ReminderRepositoryImpl repository;
  late int taskId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ReminderRepositoryImpl(database.reminderDao);
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    taskId = await TaskRepositoryImpl(database.taskDao)
        .create(title: 'Submit report', categoryId: categoryId);
  });

  tearDown(() => database.close());

  test('create persists a standalone one-time reminder', () async {
    final scheduledAt = DateTime(2026, 3, 15, 9);
    final id = await repository.create(
      scheduledAt: scheduledAt,
      message: 'Call mom',
    );

    final reminders = await repository.watchAll().first;

    expect(reminders.single.id, id);
    expect(reminders.single.scheduledAt, scheduledAt);
    expect(reminders.single.message, 'Call mom');
    expect(reminders.single.isEnabled, isTrue);
    expect(reminders.single.isTaskLinked, isFalse);
    expect(reminders.single.isRecurring, isFalse);
  });

  test('create persists a task-linked reminder with an offset', () async {
    await repository.create(taskId: taskId, offsetMinutes: 30);

    final reminder = await repository.watchForTask(taskId).first;

    expect(reminder, isNotNull);
    expect(reminder!.taskId, taskId);
    expect(reminder.offsetMinutes, 30);
    expect(reminder.isTaskLinked, isTrue);
  });

  test('watchStandalone excludes task-linked reminders', () async {
    await repository.create(taskId: taskId);
    await repository.create(scheduledAt: DateTime(2026, 3, 15));

    final standalone = await repository.watchStandalone().first;

    expect(standalone, hasLength(1));
    expect(standalone.single.taskId, isNull);
  });

  test('getAllEnabled excludes disabled reminders', () async {
    final enabledId = await repository.create(scheduledAt: DateTime(2026, 3, 15));
    final disabled = await repository.create(scheduledAt: DateTime(2026, 3, 16));
    final disabledReminder = await repository.getAllEnabled();
    final toDisable = disabledReminder.firstWhere((r) => r.id == disabled);
    await repository.update(
      Reminder(
        id: toDisable.id,
        scheduledAt: toDisable.scheduledAt,
        offsetMinutes: toDisable.offsetMinutes,
        isEnabled: false,
        createdAt: toDisable.createdAt,
      ),
    );

    final enabled = await repository.getAllEnabled();

    expect(enabled, hasLength(1));
    expect(enabled.single.id, enabledId);
  });

  test('deleteForTask removes only that task\'s reminder', () async {
    await repository.create(taskId: taskId);
    await repository.create(scheduledAt: DateTime(2026, 3, 15));

    await repository.deleteForTask(taskId);

    expect(await repository.watchForTask(taskId).first, isNull);
    expect(await repository.watchAll().first, hasLength(1));
  });

  test('delete removes a reminder by id', () async {
    final id = await repository.create(scheduledAt: DateTime(2026, 3, 15));

    await repository.delete(id);

    expect(await repository.watchAll().first, isEmpty);
  });
}
