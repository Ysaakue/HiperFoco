import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../timer/presentation/providers/timer_providers.dart';
import '../../domain/entities/category.dart';

class CategoryTile extends ConsumerWidget {
  const CategoryTile({
    required this.category,
    required this.onTap,
    required this.onToggleArchived,
    required this.onPlayTap,
    required this.onViewHistory,
    required this.isActiveSession,
    required this.isActiveSessionRunning,
    super.key,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onToggleArchived;
  final VoidCallback onPlayTap;
  final VoidCallback onViewHistory;
  final bool isActiveSession;
  final bool isActiveSessionRunning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(category.colorValue);
    final todaySeconds =
        ref.watch(todayCategoryDurationSecondsProvider(category.id)).valueOrNull ?? 0;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        child: Icon(CategoryIcons.resolve(category.iconKey)),
      ),
      title: Text(category.name),
      subtitle: Text(DurationFormatter.hms(Duration(seconds: todaySeconds))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isActiveSession
                  ? (isActiveSessionRunning
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill)
                  : Icons.play_circle_outline,
            ),
            color: isActiveSession ? color : null,
            tooltip: isActiveSession
                ? (isActiveSessionRunning ? l10n.timerPause : l10n.timerResume)
                : l10n.timerStart,
            onPressed: onPlayTap,
          ),
          PopupMenuButton<_CategoryAction>(
            onSelected: (action) {
              switch (action) {
                case _CategoryAction.toggleArchived:
                  onToggleArchived();
                case _CategoryAction.viewHistory:
                  onViewHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _CategoryAction.viewHistory,
                child: Text(l10n.timerHistory),
              ),
              PopupMenuItem(
                value: _CategoryAction.toggleArchived,
                child: Text(
                  category.isArchived
                      ? l10n.categoryUnarchive
                      : l10n.categoryArchive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CategoryAction { toggleArchived, viewHistory }
