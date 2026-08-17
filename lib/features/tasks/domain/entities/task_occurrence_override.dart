import 'package:equatable/equatable.dart';

import 'occurrence_status.dart';

class TaskOccurrenceOverride extends Equatable {
  const TaskOccurrenceOverride({
    required this.id,
    required this.taskId,
    required this.occurrenceDate,
    required this.status,
    this.rescheduledTo,
  });

  final int id;
  final int taskId;

  /// The occurrence's original (virtual) date, as computed by
  /// [RecurrenceEngine] — never the rescheduled date.
  final DateTime occurrenceDate;

  final OccurrenceStatus status;

  /// Only set when [status] is [OccurrenceStatus.rescheduled].
  final DateTime? rescheduledTo;

  @override
  List<Object?> get props =>
      [id, taskId, occurrenceDate, status, rescheduledTo];
}
