import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/reminder_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/task_occurrence_override_repository.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/task_repository.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/create_task.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/delete_task.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/set_task_status.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/update_task.dart';
import 'package:hiperfoco/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockTaskOccurrenceOverrideRepository extends Mock
    implements TaskOccurrenceOverrideRepository {}

void main() {
  late MockTaskRepository repository;

  final task = Task(
    id: 1,
    title: 'Write report',
    categoryId: 10,
    status: TaskStatus.pending,
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockTaskRepository();
  });

  group('WatchTasks', () {
    test('delegates to repository.watchAll with given filters', () {
      when(() => repository.watchAll(categoryId: 10, includeCompleted: false))
          .thenAnswer((_) => Stream.value([task]));

      final stream = WatchTasks(repository)(
        categoryId: 10,
        includeCompleted: false,
      );

      expect(stream, emits([task]));
      verify(() => repository.watchAll(categoryId: 10, includeCompleted: false))
          .called(1);
    });
  });

  group('CreateTask', () {
    test('delegates to repository.create with the given fields', () async {
      when(() => repository.create(
            title: 'Write report',
            description: null,
            categoryId: 10,
            dueDate: null,
          )).thenAnswer((_) async => 1);

      final id = await CreateTask(repository)(
        title: 'Write report',
        categoryId: 10,
      );

      expect(id, 1);
      verify(() => repository.create(
            title: 'Write report',
            description: null,
            categoryId: 10,
            dueDate: null,
          )).called(1);
    });
  });

  group('UpdateTask', () {
    test('delegates to repository.update with the task', () async {
      when(() => repository.update(task)).thenAnswer((_) async {});

      await UpdateTask(repository)(task);

      verify(() => repository.update(task)).called(1);
    });
  });

  group('SetTaskStatus', () {
    test('delegates to repository.setStatus', () async {
      when(() => repository.setStatus(1, TaskStatus.completed))
          .thenAnswer((_) async {});

      await SetTaskStatus(repository)(1, TaskStatus.completed);

      verify(() => repository.setStatus(1, TaskStatus.completed)).called(1);
    });
  });

  group('DeleteTask', () {
    late MockReminderRepository reminderRepository;
    late MockTaskOccurrenceOverrideRepository overrideRepository;

    setUp(() {
      reminderRepository = MockReminderRepository();
      overrideRepository = MockTaskOccurrenceOverrideRepository();
    });

    test('deletes the task\'s reminder and overrides before the task itself',
        () async {
      when(() => reminderRepository.deleteForTask(1)).thenAnswer((_) async {});
      when(() => overrideRepository.deleteForTask(1)).thenAnswer((_) async {});
      when(() => repository.delete(1)).thenAnswer((_) async {});

      await DeleteTask(repository, reminderRepository, overrideRepository)(1);

      verifyInOrder([
        () => reminderRepository.deleteForTask(1),
        () => overrideRepository.deleteForTask(1),
        () => repository.delete(1),
      ]);
    });
  });
}
