import 'package:flutter/material.dart';

import '../../../../core/constants/category_colors.dart';

class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    required this.selectedColorValue,
    required this.onChanged,
    super.key,
  });

  final int selectedColorValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in CategoryColors.palette)
          _ColorSwatch(
            color: color,
            isSelected: color.toARGB32() == selectedColorValue,
            onTap: () => onChanged(color.toARGB32()),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                )
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
