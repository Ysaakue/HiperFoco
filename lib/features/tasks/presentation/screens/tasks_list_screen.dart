import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_providers.dart';
import '../widgets/task_tile.dart';
import 'reminders_list_screen.dart';
import 'task_form_screen.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  bool _hideCompleted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tasksAsync =
        ref.watch(tasksListProvider(includeCompleted: !_hideCompleted));
    final categoriesAsync = ref.watch(categoriesListProvider(includeArchived: true));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.remindersTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersListScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              _hideCompleted ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            ),
            tooltip: _hideCompleted
                ? l10n.showCompletedTasks
                : l10n.hideCompletedTasks,
            onPressed: () => setState(() => _hideCompleted = !_hideCompleted),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return EmptyState(
              icon: Icons.checklist_outlined,
              message: _hideCompleted ? l10n.noPendingTasks : l10n.noTasksYet,
            );
          }
          final categoriesById = {
            for (final category in categoriesAsync.valueOrNull ?? [])
              category.id: category,
          };
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task,
                category: categoriesById[task.categoryId],
                onTap: () => _openForm(context, task: task),
                onToggleComplete: (isDone) => ref
                    .read(setTaskStatusUseCaseProvider)
                    .call(
                      task.id,
                      isDone ? TaskStatus.completed : TaskStatus.pending,
                    ),
                onDelete: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.deleteTask,
                    message: l10n.deleteTaskConfirm(task.title),
                    confirmLabel: l10n.delete,
                    cancelLabel: l10n.cancel,
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await ref.read(deleteTaskUseCaseProvider).call(task.id);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }
}
