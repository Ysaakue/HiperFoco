import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/goals/domain/entities/goal.dart';
import 'package:hiperfoco/features/goals/domain/entities/goal_step.dart';
import 'package:hiperfoco/features/goals/domain/repositories/goal_repository.dart';
import 'package:hiperfoco/features/goals/domain/repositories/goal_step_repository.dart';
import 'package:hiperfoco/features/goals/domain/usecases/create_goal.dart';
import 'package:hiperfoco/features/goals/domain/usecases/create_goal_step.dart';
import 'package:hiperfoco/features/goals/domain/usecases/delete_goal.dart';
import 'package:hiperfoco/features/goals/domain/usecases/delete_goal_step.dart';
import 'package:hiperfoco/features/goals/domain/usecases/promote_goal_step_to_task.dart';
import 'package:hiperfoco/features/goals/domain/usecases/reorder_goal_steps.dart';
import 'package:hiperfoco/features/goals/domain/usecases/set_goal_step_done.dart';
import 'package:hiperfoco/features/goals/domain/usecases/update_goal.dart';
import 'package:hiperfoco/features/goals/domain/usecases/watch_goal_steps.dart';
import 'package:hiperfoco/features/goals/domain/usecases/watch_goals.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/task_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalRepository extends Mock implements GoalRepository {}

class MockGoalStepRepository extends Mock implements GoalStepRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TaskStatus.pending);
  });

  final goal = Goal(
    id: 1,
    title: 'Learn Flutter',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final step = GoalStep(
    id: 1,
    goalId: 1,
    title: 'Read the docs',
    isDone: false,
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
  );

  group('Goal usecases', () {
    late MockGoalRepository repository;
    late MockGoalStepRepository stepRepository;

    setUp(() {
      repository = MockGoalRepository();
      stepRepository = MockGoalStepRepository();
    });

    test('WatchGoals delegates to repository.watchAll', () {
      when(() => repository.watchAll()).thenAnswer((_) => Stream.value([goal]));

      expect(WatchGoals(repository)(), emits([goal]));
    });

    test('CreateGoal delegates to repository.create', () async {
      when(() => repository.create(title: 'Learn Flutter', description: null))
          .thenAnswer((_) async => 1);

      final id = await CreateGoal(repository)(title: 'Learn Flutter');

      expect(id, 1);
    });

    test('UpdateGoal delegates to repository.update', () async {
      when(() => repository.update(goal)).thenAnswer((_) async {});

      await UpdateGoal(repository)(goal);

      verify(() => repository.update(goal)).called(1);
    });

    test('DeleteGoal deletes the goal\'s steps before the goal itself', () async {
      when(() => stepRepository.deleteForGoal(1)).thenAnswer((_) async {});
      when(() => repository.delete(1)).thenAnswer((_) async {});

      await DeleteGoal(repository, stepRepository)(1);

      verifyInOrder([
        () => stepRepository.deleteForGoal(1),
        () => repository.delete(1),
      ]);
    });
  });

  group('GoalStep usecases', () {
    late MockGoalStepRepository repository;
    late MockTaskRepository taskRepository;

    setUp(() {
      repository = MockGoalStepRepository();
      taskRepository = MockTaskRepository();
    });

    test('WatchGoalSteps delegates to repository.watchForGoal', () {
      when(() => repository.watchForGoal(1)).thenAnswer((_) => Stream.value([step]));

      expect(WatchGoalSteps(repository)(1), emits([step]));
    });

    test('CreateGoalStep delegates to repository.create', () async {
      when(() => repository.create(goalId: 1, title: 'Read the docs'))
          .thenAnswer((_) async => 1);

      final id = await CreateGoalStep(repository)(goalId: 1, title: 'Read the docs');

      expect(id, 1);
    });

    test('SetGoalStepDone delegates to repository.setDone', () async {
      when(() => repository.getById(1)).thenAnswer((_) async => step);
      when(() => repository.setDone(1, true)).thenAnswer((_) async {});

      await SetGoalStepDone(repository, taskRepository)(1, true);

      verify(() => repository.setDone(1, true)).called(1);
    });

    test(
        'SetGoalStepDone also mirrors isDone onto the linked task, if any',
        () async {
      final linkedStep = GoalStep(
        id: 1,
        goalId: 1,
        title: 'Read the docs',
        isDone: false,
        sortOrder: 0,
        linkedTaskId: 99,
        createdAt: DateTime(2026, 1, 1),
      );
      when(() => repository.getById(1)).thenAnswer((_) async => linkedStep);
      when(() => repository.setDone(1, true)).thenAnswer((_) async {});
      when(() => taskRepository.setStatus(99, TaskStatus.completed))
          .thenAnswer((_) async {});

      await SetGoalStepDone(repository, taskRepository)(1, true);

      verify(() => taskRepository.setStatus(99, TaskStatus.completed))
          .called(1);
    });

    test('SetGoalStepDone leaves unlinked-step tasks alone', () async {
      when(() => repository.getById(1)).thenAnswer((_) async => step);
      when(() => repository.setDone(1, true)).thenAnswer((_) async {});

      await SetGoalStepDone(repository, taskRepository)(1, true);

      verifyNever(() => taskRepository.setStatus(any(), any()));
    });

    test('ReorderGoalSteps delegates to repository.reorder', () async {
      when(() => repository.reorder([3, 1, 2])).thenAnswer((_) async {});

      await ReorderGoalSteps(repository)([3, 1, 2]);

      verify(() => repository.reorder([3, 1, 2])).called(1);
    });

    test('DeleteGoalStep delegates to repository.delete', () async {
      when(() => repository.delete(1)).thenAnswer((_) async {});

      await DeleteGoalStep(repository)(1);

      verify(() => repository.delete(1)).called(1);
    });

    test('PromoteGoalStepToTask creates the task then links the step', () async {
      when(() => taskRepository.create(title: 'Read the docs', categoryId: 10))
          .thenAnswer((_) async => 99);
      when(() => repository.setLinkedTask(1, 99)).thenAnswer((_) async {});

      final taskId = await PromoteGoalStepToTask(repository, taskRepository)(
        stepId: 1,
        title: 'Read the docs',
        categoryId: 10,
      );

      expect(taskId, 99);
      verifyInOrder([
        () => taskRepository.create(title: 'Read the docs', categoryId: 10),
        () => repository.setLinkedTask(1, 99),
      ]);
    });
  });
}
