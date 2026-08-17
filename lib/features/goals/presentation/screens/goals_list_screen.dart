import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import 'goal_detail_screen.dart';
import 'goal_form_screen.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(icon: Icons.flag_outlined, message: l10n.noGoalsYet);
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalTile(
                goal: goal,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
                ),
                onDelete: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.deleteGoal,
                    message: l10n.deleteGoalConfirm(goal.title),
                    confirmLabel: l10n.delete,
                    cancelLabel: l10n.cancel,
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await ref.read(deleteGoalUseCaseProvider).call(goal.id);
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GoalFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(goalStepsProvider(goal.id)).valueOrNull ?? const [];
    final done = steps.where((step) => step.isDone).length;
    final total = steps.length;

    return ListTile(
      onTap: onTap,
      title: Text(goal.title),
      subtitle: total == 0
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: done / total),
                ),
                const SizedBox(height: 4),
                Text('$done/$total'),
              ],
            ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
