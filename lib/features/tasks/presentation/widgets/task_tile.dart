import 'package:flutter/material.dart';

import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.category,
    required this.onToggleComplete,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Task task;
  final Category? category;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final categoryColor =
        category != null ? Color(category!.colorValue) : Colors.grey;

    return ListTile(
      onTap: onTap,
      leading: Checkbox(
        value: isCompleted,
        onChanged: (value) => onToggleComplete(value ?? false),
      ),
      title: Text(
        task.title,
        style: isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: category != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(category!.name),
              ],
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
