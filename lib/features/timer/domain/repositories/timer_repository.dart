import '../entities/timer_interval.dart';
import '../entities/timer_session.dart';

abstract interface class TimerRepository {
  /// The session that is currently running or paused (at most one at a
  /// time), or null when nothing is active.
  Stream<TimerSession?> watchActiveSession();

  /// Starts a new session for [categoryId]. If another session is
  /// currently active (running or paused), it is stopped first.
  Future<int> start({required int categoryId, int? taskId});

  Future<void> pause(int sessionId);

  /// Resumes a paused session.
  Future<void> resume(int sessionId);

  Future<void> stop(int sessionId);

  /// Seconds accumulated today (local calendar day) for [categoryId],
  /// counting only closed intervals.
  Stream<int> watchTodayDurationSecondsForCategory(int categoryId);

  /// Seconds accumulated today across all categories, counting only
  /// closed intervals.
  Stream<int> watchTodayTotalDurationSeconds();

  /// Every interval started on [day] (local calendar day), oldest first.
  Stream<List<TimerInterval>> watchIntervalsForDay(DateTime day);

  /// The category a given interval's session belongs to.
  Future<int?> categoryIdForSession(int sessionId);
}
