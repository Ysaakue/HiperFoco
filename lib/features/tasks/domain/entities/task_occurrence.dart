import 'package:equatable/equatable.dart';

import 'occurrence_status.dart';
import 'task.dart';

/// A single day's instance of a task — either a non-recurring task's due
/// date, or one virtual occurrence of a recurring task — with any override
/// status resolved. Never persisted; computed on demand by
/// [TaskOccurrenceCalculator].
class TaskOccurrence extends Equatable {
  const TaskOccurrence({required this.task, required this.date, this.status});

  final Task task;
  final DateTime date;
  final OccurrenceStatus? status;

  bool get isDone => status == OccurrenceStatus.done;
  bool get isSkipped => status == OccurrenceStatus.skipped;

  @override
  List<Object?> get props => [task, date, status];
}
