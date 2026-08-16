import 'package:flutter/material.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/category.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.onTap,
    required this.onToggleArchived,
    super.key,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onToggleArchived;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(category.colorValue);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        child: Icon(CategoryIcons.resolve(category.iconKey)),
      ),
      title: Text(category.name),
      subtitle: Text(DurationFormatter.hms(Duration.zero)),
      trailing: PopupMenuButton<_CategoryAction>(
        onSelected: (action) {
          if (action == _CategoryAction.toggleArchived) onToggleArchived();
        },
        itemBuilder: (context) => [
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
    );
  }
}

enum _CategoryAction { toggleArchived }
