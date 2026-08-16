import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/set_task_status.dart';
import '../../domain/usecases/update_task.dart';
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
  return DeleteTask(ref.watch(taskRepositoryProvider));
}

@riverpod
Stream<List<Task>> tasksList(Ref ref, {int? categoryId, bool includeCompleted = true}) {
  return ref.watch(watchTasksUseCaseProvider)(
    categoryId: categoryId,
    includeCompleted: includeCompleted,
  );
}
