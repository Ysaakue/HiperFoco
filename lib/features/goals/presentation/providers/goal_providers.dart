import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../data/repositories/goal_step_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_step.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/goal_step_repository.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/create_goal_step.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/delete_goal_step.dart';
import '../../domain/usecases/promote_goal_step_to_task.dart';
import '../../domain/usecases/reorder_goal_steps.dart';
import '../../domain/usecases/set_goal_step_done.dart';
import '../../domain/usecases/update_goal.dart';
import '../../domain/usecases/watch_goal_steps.dart';
import '../../domain/usecases/watch_goals.dart';

part 'goal_providers.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).goalDao;
  return GoalRepositoryImpl(dao);
}

@Riverpod(keepAlive: true)
GoalStepRepository goalStepRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).goalStepDao;
  return GoalStepRepositoryImpl(dao);
}

@riverpod
WatchGoals watchGoalsUseCase(Ref ref) {
  return WatchGoals(ref.watch(goalRepositoryProvider));
}

@riverpod
CreateGoal createGoalUseCase(Ref ref) {
  return CreateGoal(ref.watch(goalRepositoryProvider));
}

@riverpod
UpdateGoal updateGoalUseCase(Ref ref) {
  return UpdateGoal(ref.watch(goalRepositoryProvider));
}

@riverpod
DeleteGoal deleteGoalUseCase(Ref ref) {
  return DeleteGoal(
    ref.watch(goalRepositoryProvider),
    ref.watch(goalStepRepositoryProvider),
  );
}

@riverpod
Stream<List<Goal>> goalsList(Ref ref) {
  return ref.watch(watchGoalsUseCaseProvider)();
}

@riverpod
WatchGoalSteps watchGoalStepsUseCase(Ref ref) {
  return WatchGoalSteps(ref.watch(goalStepRepositoryProvider));
}

@riverpod
CreateGoalStep createGoalStepUseCase(Ref ref) {
  return CreateGoalStep(ref.watch(goalStepRepositoryProvider));
}

@riverpod
SetGoalStepDone setGoalStepDoneUseCase(Ref ref) {
  return SetGoalStepDone(
    ref.watch(goalStepRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
}

@riverpod
ReorderGoalSteps reorderGoalStepsUseCase(Ref ref) {
  return ReorderGoalSteps(ref.watch(goalStepRepositoryProvider));
}

@riverpod
DeleteGoalStep deleteGoalStepUseCase(Ref ref) {
  return DeleteGoalStep(ref.watch(goalStepRepositoryProvider));
}

@riverpod
PromoteGoalStepToTask promoteGoalStepToTaskUseCase(Ref ref) {
  return PromoteGoalStepToTask(
    ref.watch(goalStepRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
}

@riverpod
Stream<List<GoalStep>> goalSteps(Ref ref, int goalId) {
  return ref.watch(watchGoalStepsUseCaseProvider)(goalId);
}
