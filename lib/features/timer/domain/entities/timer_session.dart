import 'package:equatable/equatable.dart';

import 'timer_session_status.dart';

class TimerSession extends Equatable {
  const TimerSession({
    required this.id,
    this.taskId,
    required this.categoryId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.totalDurationSeconds,
    this.currentIntervalStartedAt,
  });

  final int id;
  final int? taskId;
  final int categoryId;
  final TimerSessionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// Sum of every *closed* interval's duration. Does not include the
  /// currently open interval while [status] is running.
  final int totalDurationSeconds;

  /// Start time of the currently open interval. Non-null only while
  /// [status] is [TimerSessionStatus.running].
  final DateTime? currentIntervalStartedAt;

  bool get isRunning => status == TimerSessionStatus.running;

  /// Total elapsed duration as of [now], including the live portion of an
  /// open interval when the session is running.
  Duration elapsedAt(DateTime now) {
    final base = Duration(seconds: totalDurationSeconds);
    final openStart = currentIntervalStartedAt;
    if (isRunning && openStart != null) {
      return base + now.difference(openStart);
    }
    return base;
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        categoryId,
        status,
        startedAt,
        completedAt,
        totalDurationSeconds,
        currentIntervalStartedAt,
      ];
}
