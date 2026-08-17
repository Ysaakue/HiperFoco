import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/repositories/recurrence_rule_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/task_occurrence_override_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_occurrence.dart';
import '../../domain/entities/task_occurrence_override.dart';
import '../../domain/repositories/notification_scheduler.dart';
import '../../domain/repositories/recurrence_rule_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/task_occurrence_override_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/services/reminder_scheduling_service.dart';
import '../../domain/services/task_occurrence_calculator.dart';
import '../../domain/usecases/clear_occurrence_override.dart';
import '../../domain/usecases/create_recurrence_rule.dart';
import '../../domain/usecases/create_reminder.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_recurrence_rule.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_recurrence_rule.dart';
import '../../domain/usecases/set_occurrence_status.dart';
import '../../domain/usecases/set_task_status.dart';
import '../../domain/usecases/update_recurrence_rule.dart';
import '../../domain/usecases/update_reminder.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_occurrence_overrides_between.dart';
import '../../domain/usecases/watch_reminder_for_task.dart';
import '../../domain/usecases/watch_reminders.dart';
import '../../domain/usecases/watch_standalone_reminders.dart';
import '../../domain/usecases/watch_tasks.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).taskDao;
  return TaskRepositoryImpl(dao);
}

@riverpod
WatchTasks watchTasksUseCase(Ref ref) {
  return WatchTasks(ref.watch(taskRepositoryProvider));
}

@riverpod
CreateTask createTaskUseCase(Ref ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
}

@riverpod
UpdateTask updateTaskUseCase(Ref ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
}

@riverpod
SetTaskStatus setTaskStatusUseCase(Ref ref) {
  return SetTaskStatus(ref.watch(taskRepositoryProvider));
}

@riverpod
DeleteTask deleteTaskUseCase(Ref ref) {
  return DeleteTask(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderRepositoryProvider),
    ref.watch(taskOccurrenceOverrideRepositoryProvider),
  );
}

@riverpod
Stream<List<Task>> tasksList(Ref ref, {int? categoryId, bool includeCompleted = true}) {
  return ref.watch(watchTasksUseCaseProvider)(
    categoryId: categoryId,
    includeCompleted: includeCompleted,
  );
}

// --- Recurrence rules -------------------------------------------------

@Riverpod(keepAlive: true)
RecurrenceRuleRepository recurrenceRuleRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).recurrenceRuleDao;
  return RecurrenceRuleRepositoryImpl(dao);
}

@riverpod
CreateRecurrenceRule createRecurrenceRuleUseCase(Ref ref) {
  return CreateRecurrenceRule(ref.watch(recurrenceRuleRepositoryProvider));
}

@riverpod
UpdateRecurrenceRule updateRecurrenceRuleUseCase(Ref ref) {
  return UpdateRecurrenceRule(ref.watch(recurrenceRuleRepositoryProvider));
}

@riverpod
DeleteRecurrenceRule deleteRecurrenceRuleUseCase(Ref ref) {
  return DeleteRecurrenceRule(ref.watch(recurrenceRuleRepositoryProvider));
}

@riverpod
GetRecurrenceRule getRecurrenceRuleUseCase(Ref ref) {
  return GetRecurrenceRule(ref.watch(recurrenceRuleRepositoryProvider));
}

@riverpod
Future<RecurrenceRule?> recurrenceRuleById(Ref ref, int id) {
  return ref.watch(getRecurrenceRuleUseCaseProvider)(id);
}

// --- Task occurrence overrides -----------------------------------------

@Riverpod(keepAlive: true)
TaskOccurrenceOverrideRepository taskOccurrenceOverrideRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).taskOccurrenceOverrideDao;
  return TaskOccurrenceOverrideRepositoryImpl(dao);
}

@riverpod
SetOccurrenceStatus setOccurrenceStatusUseCase(Ref ref) {
  return SetOccurrenceStatus(ref.watch(taskOccurrenceOverrideRepositoryProvider));
}

@riverpod
ClearOccurrenceOverride clearOccurrenceOverrideUseCase(Ref ref) {
  return ClearOccurrenceOverride(ref.watch(taskOccurrenceOverrideRepositoryProvider));
}

@riverpod
WatchOccurrenceOverridesBetween watchOccurrenceOverridesBetweenUseCase(Ref ref) {
  return WatchOccurrenceOverridesBetween(
    ref.watch(taskOccurrenceOverrideRepositoryProvider),
  );
}

@riverpod
Stream<List<TaskOccurrenceOverride>> occurrenceOverridesBetween(
  Ref ref,
  DateTime start,
  DateTime end,
) {
  return ref.watch(watchOccurrenceOverridesBetweenUseCaseProvider)(start, end);
}

/// Combines recurring/non-recurring tasks, their recurrence rules, and any
/// per-occurrence overrides into the flat list a calendar view renders.
@riverpod
Stream<List<TaskOccurrence>> occurrencesForRange(
  Ref ref,
  DateTime start,
  DateTime end,
) async* {
  final tasks = await ref.watch(tasksListProvider(includeCompleted: true).future);
  final overrides =
      await ref.watch(occurrenceOverridesBetweenProvider(start, end).future);

  final ruleIds = {
    for (final task in tasks)
      if (task.recurrenceRuleId != null) task.recurrenceRuleId!,
  };
  final rulesById = <int, RecurrenceRule>{};
  for (final id in ruleIds) {
    final rule = await ref.watch(recurrenceRuleByIdProvider(id).future);
    if (rule != null) rulesById[id] = rule;
  }

  yield const TaskOccurrenceCalculator().occurrencesBetween(
    tasks: tasks,
    rulesById: rulesById,
    overrides: overrides,
    start: start,
    end: end,
  );
}

// --- Reminders ----------------------------------------------------------

@Riverpod(keepAlive: true)
ReminderRepository reminderRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).reminderDao;
  return ReminderRepositoryImpl(dao);
}

@riverpod
CreateReminder createReminderUseCase(Ref ref) {
  return CreateReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
UpdateReminder updateReminderUseCase(Ref ref) {
  return UpdateReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
DeleteReminder deleteReminderUseCase(Ref ref) {
  return DeleteReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
WatchReminders watchRemindersUseCase(Ref ref) {
  return WatchReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
WatchStandaloneReminders watchStandaloneRemindersUseCase(Ref ref) {
  return WatchStandaloneReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
WatchReminderForTask watchReminderForTaskUseCase(Ref ref) {
  return WatchReminderForTask(ref.watch(reminderRepositoryProvider));
}

@riverpod
Stream<List<Reminder>> remindersList(Ref ref) {
  return ref.watch(watchRemindersUseCaseProvider)();
}

@riverpod
Stream<List<Reminder>> standaloneRemindersList(Ref ref) {
  return ref.watch(watchStandaloneRemindersUseCaseProvider)();
}

@riverpod
Stream<Reminder?> reminderForTask(Ref ref, int taskId) {
  return ref.watch(watchReminderForTaskUseCaseProvider)(taskId);
}

// --- Notifications --------------------------------------------------------

@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) {
  throw UnimplementedError(
    'notificationSchedulerProvider must be overridden in main() before runApp.',
  );
}

@Riverpod(keepAlive: true)
ReminderSchedulingService reminderSchedulingService(Ref ref) {
  return ReminderSchedulingService(
    ref.watch(reminderRepositoryProvider),
    ref.watch(taskRepositoryProvider),
    ref.watch(recurrenceRuleRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  );
}
