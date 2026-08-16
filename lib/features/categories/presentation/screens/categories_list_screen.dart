import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../timer/presentation/providers/timer_providers.dart';
import '../../../timer/presentation/screens/timer_history_screen.dart';
import '../../../timer/presentation/screens/timer_screen.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../widgets/category_tile.dart';
import 'category_form_screen.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: _showArchived));
    final activeSession = ref.watch(activeTimerSessionProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            tooltip: _showArchived
                ? l10n.hideArchivedCategories
                : l10n.showArchivedCategories,
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              message:
                  _showArchived ? l10n.noArchivedCategories : l10n.noCategoriesYet,
            );
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isActive = activeSession?.categoryId == category.id;
              return Opacity(
                opacity: category.isArchived ? 0.5 : 1,
                child: CategoryTile(
                  category: category,
                  onTap: () => _openForm(context, category: category),
                  onToggleArchived: () => ref
                      .read(setCategoryArchivedUseCaseProvider)
                      .call(category.id, !category.isArchived),
                  isActiveSession: isActive,
                  isActiveSessionRunning: isActive && (activeSession?.isRunning ?? false),
                  onPlayTap: () => _onPlayTap(context, category, activeSession?.categoryId),
                  onViewHistory: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimerHistoryScreen()),
                  ),
                ),
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

  Future<void> _onPlayTap(
    BuildContext context,
    Category category,
    int? activeSessionCategoryId,
  ) async {
    if (activeSessionCategoryId != category.id) {
      await ref.read(startTimerUseCaseProvider).call(categoryId: category.id);
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TimerScreen()),
      );
    }
  }

  void _openForm(BuildContext context, {Category? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(category: category),
      ),
    );
  }
}
