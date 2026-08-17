import '../entities/timer_history_entry.dart';
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

  /// Compacts every *closed* interval started on [day] into
  /// [TimerHistoryEntry] buckets grouped by (category, task), then deletes
  /// those interval rows. An interval still open at [day]'s end (a session
  /// left running across midnight) is split: the portion up to midnight is
  /// archived and a fresh interval picks up at the next day's start for the
  /// same session, which keeps running/paused sessions alive indefinitely.
  /// Idempotent — re-archiving a day with nothing left to archive is a
  /// no-op.
  Future<void> archiveDay(DateTime day);

  /// The compacted totals for [day], one entry per (category, task)
  /// bucket. Empty for a day that either had no activity or hasn't been
  /// archived yet.
  Stream<List<TimerHistoryEntry>> watchArchivedDay(DateTime day);

  /// The compacted totals for every already-archived day in the half-open
  /// range `[start, end)`. Today is never included here even if it falls in
  /// range — it's still "hot" and hasn't been archived yet; callers that
  /// need today's contribution should combine this with
  /// [watchIntervalsForDay].
  Stream<List<TimerHistoryEntry>> watchArchivedBetween(
    DateTime start,
    DateTime end,
  );

  /// Deletes archived history strictly older than [months] months ago.
  Future<void> purgeHistoryOlderThan(int months);
}
