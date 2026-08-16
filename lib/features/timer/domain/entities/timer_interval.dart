import 'package:equatable/equatable.dart';

class TimerInterval extends Equatable {
  const TimerInterval({
    required this.id,
    required this.sessionId,
    required this.categoryId,
    this.taskId,
    required this.startedAt,
    this.endedAt,
  });

  final int id;
  final int sessionId;

  /// Denormalized from the parent session, for display without a join at
  /// the presentation layer.
  final int categoryId;
  final int? taskId;

  final DateTime startedAt;
  final DateTime? endedAt;

  bool get isOpen => endedAt == null;

  Duration elapsedAt(DateTime now) => (endedAt ?? now).difference(startedAt);

  @override
  List<Object?> get props =>
      [id, sessionId, categoryId, taskId, startedAt, endedAt];
}
