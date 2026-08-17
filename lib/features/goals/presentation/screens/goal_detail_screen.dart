import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_step.dart';
import '../providers/goal_providers.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({required this.goal, super.key});

  final Goal goal;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final _newStepController = TextEditingController();

  @override
  void dispose() {
    _newStepController.dispose();
    super.dispose();
  }

  Future<void> _addStep() async {
    final title = _newStepController.text.trim();
    if (title.isEmpty) return;
    await ref
        .read(createGoalStepUseCaseProvider)
        .call(goalId: widget.goal.id, title: title);
    _newStepController.clear();
  }

  Future<void> _promote(GoalStep step) async {
    final l10n = AppLocalizations.of(context)!;
    // `.future` (not `.valueOrNull`) awaits the stream's first emission —
    // `ref.read` on a provider nothing else in the tree is watching yet
    // would otherwise return the initial AsyncLoading state synchronously,
    // making a real category list look empty for an instant.
    final categories = await ref.read(categoriesListProvider().future);
    if (!mounted) return;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noCategoriesYet)));
      return;
    }

    final categoryId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.promoteToTaskCategoryPrompt),
        children: [
          for (final category in categories)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(category.id),
              child: Text(category.name),
            ),
        ],
      ),
    );
    if (categoryId == null) return;

    await ref.read(promoteGoalStepToTaskUseCaseProvider).call(
          stepId: step.id,
          title: step.title,
          categoryId: categoryId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stepsAsync = ref.watch(goalStepsProvider(widget.goal.id));
    final description = widget.goal.description;

    return Scaffold(
      appBar: AppBar(title: Text(widget.goal.title)),
      body: Column(
        children: [
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(description),
              ),
            ),
          Expanded(
            child: stepsAsync.when(
              data: (steps) {
                if (steps.isEmpty) {
                  return EmptyState(
                    icon: Icons.checklist_outlined,
                    message: l10n.noStepsYet,
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _StepTile(
                      key: ValueKey(step.id),
                      step: step,
                      onToggleDone: (value) => ref
                          .read(setGoalStepDoneUseCaseProvider)
                          .call(step.id, value),
                      onDelete: () =>
                          ref.read(deleteGoalStepUseCaseProvider).call(step.id),
                      onPromote:
                          step.isPromoted ? null : () => _promote(step),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    final reordered = [...steps];
                    if (newIndex > oldIndex) newIndex -= 1;
                    final moved = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, moved);
                    ref.read(reorderGoalStepsUseCaseProvider).call(
                          [for (final s in reordered) s.id],
                        );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('$error')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newStepController,
                      decoration: InputDecoration(hintText: l10n.addStepHint),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _addStep(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addStep,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required super.key,
    required this.step,
    required this.onToggleDone,
    required this.onDelete,
    this.onPromote,
  });

  final GoalStep step;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback? onPromote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Checkbox(
        value: step.isDone,
        onChanged: (value) => onToggleDone(value ?? false),
      ),
      title: Text(
        step.title,
        style: step.isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: step.isPromoted ? Text(l10n.promoted) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPromote != null)
            IconButton(
              icon: const Icon(Icons.task_alt_outlined),
              tooltip: l10n.promoteToTask,
              onPressed: onPromote,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
