import 'package:equatable/equatable.dart';

/// A compacted, read-only summary of a single (day, category, task) bucket
/// from the archived history — no per-interval detail survives archiving.
class TimerHistoryEntry extends Equatable {
  const TimerHistoryEntry({
    required this.date,
    required this.categoryId,
    this.taskId,
    required this.totalDurationSeconds,
    required this.sessionCount,
  });

  final DateTime date;
  final int categoryId;
  final int? taskId;
  final int totalDurationSeconds;
  final int sessionCount;

  @override
  List<Object?> get props =>
      [date, categoryId, taskId, totalDurationSeconds, sessionCount];
}
