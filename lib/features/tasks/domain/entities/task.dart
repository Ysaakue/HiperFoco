import 'package:equatable/equatable.dart';

import 'task_status.dart';

/// Sentinel default for [Task.copyWith]'s nullable fields, distinguishing
/// "not provided, keep current value" from "explicitly provided as null,
/// clear it" — a plain `field ?? this.field` fallback can never express the
/// latter.
const _unset = Object();

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.status,
    this.dueDate,
    this.recurrenceRuleId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final int id;
  final String title;
  final String? description;
  final int categoryId;
  final TaskStatus status;
  final DateTime? dueDate;
  final int? recurrenceRuleId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isRecurring => recurrenceRuleId != null;

  Task copyWith({
    String? title,
    Object? description = _unset,
    int? categoryId,
    TaskStatus? status,
    Object? dueDate = _unset,
    Object? recurrenceRuleId = _unset,
    int? sortOrder,
    DateTime? updatedAt,
    Object? completedAt = _unset,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      recurrenceRuleId: identical(recurrenceRuleId, _unset)
          ? this.recurrenceRuleId
          : recurrenceRuleId as int?,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        status,
        dueDate,
        recurrenceRuleId,
        sortOrder,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
