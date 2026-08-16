import 'package:flutter/material.dart';

import '../../../../core/constants/category_icons.dart';

class IconPickerGrid extends StatelessWidget {
  const IconPickerGrid({
    required this.selectedKey,
    required this.accentColor,
    required this.onChanged,
    super.key,
  });

  final String selectedKey;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in CategoryIcons.catalog.entries)
          InkWell(
            onTap: () => onChanged(entry.key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: entry.key == selectedKey
                    ? accentColor.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: entry.key == selectedKey
                    ? Border.all(color: accentColor, width: 2)
                    : null,
              ),
              child: Icon(
                entry.value,
                color: entry.key == selectedKey
                    ? accentColor
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
