import 'package:equatable/equatable.dart';

class GoalStep extends Equatable {
  const GoalStep({
    required this.id,
    required this.goalId,
    required this.title,
    required this.isDone,
    required this.sortOrder,
    this.linkedTaskId,
    required this.createdAt,
  });

  final int id;
  final int goalId;
  final String title;
  final bool isDone;
  final int sortOrder;
  final int? linkedTaskId;
  final DateTime createdAt;

  bool get isPromoted => linkedTaskId != null;

  @override
  List<Object?> get props =>
      [id, goalId, title, isDone, sortOrder, linkedTaskId, createdAt];
}
