import 'package:equatable/equatable.dart';

import 'task_status.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.status,
    this.dueDate,
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
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({
    String? title,
    String? description,
    int? categoryId,
    TaskStatus? status,
    DateTime? dueDate,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
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
        sortOrder,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
