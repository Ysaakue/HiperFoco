import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../../features/timer/domain/entities/timer_session_status.dart';
import '../app_database.dart';
import '../tables/timer_history_daily_table.dart';
import '../tables/timer_intervals_table.dart';
import '../tables/timer_sessions_table.dart';

part 'timer_dao.g.dart';

class _Bucket {
  int totalSeconds = 0;
  final Set<int> sessionIds = {};
}

@DriftAccessor(tables: [TimerSessions, TimerIntervals, TimerHistoryDaily])
class TimerDao extends DatabaseAccessor<AppDatabase> with _$TimerDaoMixin {
  TimerDao(super.db);

  Stream<TimerSessionRow?> watchActiveSession() {
    final query = select(timerSessions)
      ..where((t) => t.status.isInValues(
            [TimerSessionStatus.running, TimerSessionStatus.paused],
          ))
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<TimerSessionRow?> getSessionById(int sessionId) =>
      (select(timerSessions)..where((t) => t.id.equals(sessionId)))
          .getSingleOrNull();

  Future<int> startSession({required int categoryId, int? taskId}) {
    return attachedDatabase.transaction(() async {
      final active = await (select(timerSessions)
            ..where((t) => t.status.isInValues(
                  [TimerSessionStatus.running, TimerSessionStatus.paused],
                )))
          .getSingleOrNull();
      if (active != null) {
        await _stopSessionInternal(active);
      }

      final now = clock.now();
      final newId = await into(timerSessions).insert(
        TimerSessionsCompanion.insert(
          categoryId: categoryId,
          taskId: Value(taskId),
          status: Value(TimerSessionStatus.running),
          startedAt: Value(now),
          currentIntervalStartedAt: Value(now),
        ),
      );
      await into(timerIntervals).insert(
        TimerIntervalsCompanion.insert(sessionId: newId, startedAt: now),
      );
      return newId;
    });
  }

  Future<void> pauseSession(int sessionId) {
    return attachedDatabase.transaction(() async {
      final session = await getSessionById(sessionId);
      if (session == null || session.status != TimerSessionStatus.running) {
        return;
      }
      final now = clock.now();
      final addedSeconds = await _closeOpenInterval(session.id, now);
      await (update(timerSessions)..where((t) => t.id.equals(session.id)))
          .write(
        TimerSessionsCompanion(
          status: const Value(TimerSessionStatus.paused),
          currentIntervalStartedAt: const Value(null),
          totalDurationSeconds:
              Value(session.totalDurationSeconds + addedSeconds),
        ),
      );
    });
  }

  /// Resumes a paused session. Since starting a *different* session always
  /// stops (not pauses) whatever was previously active, at most one session
  /// can be paused at a time, so there is never another session to reconcile
  /// here.
  Future<void> resumeSession(int sessionId) {
    return attachedDatabase.transaction(() async {
      final session = await getSessionById(sessionId);
      if (session == null || session.status != TimerSessionStatus.paused) {
        return;
      }

      final now = clock.now();
      await into(timerIntervals).insert(
        TimerIntervalsCompanion.insert(sessionId: sessionId, startedAt: now),
      );
      await (update(timerSessions)..where((t) => t.id.equals(sessionId)))
          .write(
        TimerSessionsCompanion(
          status: const Value(TimerSessionStatus.running),
          currentIntervalStartedAt: Value(now),
        ),
      );
    });
  }

  Future<void> stopSession(int sessionId) {
    return attachedDatabase.transaction(() async {
      final session = await getSessionById(sessionId);
      if (session == null || session.status == TimerSessionStatus.completed) {
        return;
      }
      await _stopSessionInternal(session);
    });
  }

  /// Closes the open interval (if any) for [session] and marks it
  /// completed, folding the just-closed interval's duration into the
  /// cached total. Used both by the public [stopSession] and internally
  /// whenever starting a new session needs to retire whatever was active.
  Future<void> _stopSessionInternal(TimerSessionRow session) async {
    final now = clock.now();
    final addedSeconds = await _closeOpenInterval(session.id, now);
    await (update(timerSessions)..where((t) => t.id.equals(session.id))).write(
      TimerSessionsCompanion(
        status: const Value(TimerSessionStatus.completed),
        completedAt: Value(now),
        currentIntervalStartedAt: const Value(null),
        totalDurationSeconds:
            Value(session.totalDurationSeconds + addedSeconds),
      ),
    );
  }

  /// Closes the open interval for [sessionId] (if any) at [endedAt] and
  /// returns the number of seconds it lasted, or 0 if there was none open.
  Future<int> _closeOpenInterval(int sessionId, DateTime endedAt) async {
    final openInterval = await (select(timerIntervals)
          ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull()))
        .getSingleOrNull();
    if (openInterval == null) return 0;
    await (update(timerIntervals)..where((t) => t.id.equals(openInterval.id)))
        .write(TimerIntervalsCompanion(endedAt: Value(endedAt)));
    return endedAt.difference(openInterval.startedAt).inSeconds;
  }

  Stream<int> watchTotalClosedSecondsForCategoryBetween(
    int categoryId,
    DateTime start,
    DateTime end,
  ) {
    final query = select(timerIntervals).join([
      innerJoin(
        timerSessions,
        timerSessions.id.equalsExp(timerIntervals.sessionId),
      ),
    ])
      ..where(timerSessions.categoryId.equals(categoryId))
      ..where(timerIntervals.endedAt.isNotNull())
      ..where(timerIntervals.startedAt.isBiggerOrEqualValue(start))
      ..where(timerIntervals.startedAt.isSmallerThanValue(end));
    return query.watch().map(_sumClosedIntervals);
  }

  Stream<int> watchTotalClosedSecondsBetween(DateTime start, DateTime end) {
    final query = select(timerIntervals)
      ..where(
        (t) =>
            t.endedAt.isNotNull() &
            t.startedAt.isBiggerOrEqualValue(start) &
            t.startedAt.isSmallerThanValue(end),
      );
    return query.watch().map(
          (rows) => rows.fold<int>(
            0,
            (sum, r) => sum + r.endedAt!.difference(r.startedAt).inSeconds,
          ),
        );
  }

  int _sumClosedIntervals(List<TypedResult> rows) {
    var total = 0;
    for (final row in rows) {
      final interval = row.readTable(timerIntervals);
      total += interval.endedAt!.difference(interval.startedAt).inSeconds;
    }
    return total;
  }

  Stream<List<({TimerIntervalRow interval, int categoryId, int? taskId})>>
      watchIntervalsForDay(DateTime start, DateTime end) {
    final query = select(timerIntervals).join([
      innerJoin(
        timerSessions,
        timerSessions.id.equalsExp(timerIntervals.sessionId),
      ),
    ])
      ..where(timerIntervals.startedAt.isBiggerOrEqualValue(start))
      ..where(timerIntervals.startedAt.isSmallerThanValue(end))
      ..orderBy([OrderingTerm.asc(timerIntervals.startedAt)]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              (
                interval: row.readTable(timerIntervals),
                categoryId: row.readTable(timerSessions).categoryId,
                taskId: row.readTable(timerSessions).taskId,
              ),
          ],
        );
  }

  /// See [TimerRepository.archiveDay] for the full contract.
  Future<void> archiveDay(DateTime dayStart, DateTime dayEnd) {
    return attachedDatabase.transaction(() async {
      // 1. Split any interval still open that started before this day ends
      //    — a session left running across the midnight boundary. The
      //    closed portion is picked up by step 2 below; the continuation
      //    keeps the session alive starting at the next day.
      final openIntervals = await (select(timerIntervals)
            ..where(
              (t) => t.endedAt.isNull() & t.startedAt.isSmallerThanValue(dayEnd),
            ))
          .get();
      for (final interval in openIntervals) {
        await (update(timerIntervals)..where((t) => t.id.equals(interval.id)))
            .write(TimerIntervalsCompanion(endedAt: Value(dayEnd)));
        await into(timerIntervals).insert(
          TimerIntervalsCompanion.insert(
            sessionId: interval.sessionId,
            startedAt: dayEnd,
          ),
        );
        await (update(timerSessions)
              ..where((t) => t.id.equals(interval.sessionId)))
            .write(
          TimerSessionsCompanion(currentIntervalStartedAt: Value(dayEnd)),
        );
      }

      // 2. Bucket every closed interval that started on this day by
      //    (category, task).
      final query = select(timerIntervals).join([
        innerJoin(
          timerSessions,
          timerSessions.id.equalsExp(timerIntervals.sessionId),
        ),
      ])
        ..where(timerIntervals.startedAt.isBiggerOrEqualValue(dayStart))
        ..where(timerIntervals.startedAt.isSmallerThanValue(dayEnd))
        ..where(timerIntervals.endedAt.isNotNull());
      final rows = await query.get();
      if (rows.isEmpty) return;

      final buckets = <(int, int?), _Bucket>{};
      final archivedIntervalIds = <int>[];
      final touchedSessionIds = <int>{};
      for (final row in rows) {
        final interval = row.readTable(timerIntervals);
        final session = row.readTable(timerSessions);
        final key = (session.categoryId, session.taskId);
        final bucket = buckets.putIfAbsent(key, () => _Bucket());
        bucket.totalSeconds +=
            interval.endedAt!.difference(interval.startedAt).inSeconds;
        bucket.sessionIds.add(session.id);
        archivedIntervalIds.add(interval.id);
        touchedSessionIds.add(session.id);
      }

      // 3. Fold each bucket into the compacted history table.
      for (final entry in buckets.entries) {
        final (categoryId, taskId) = entry.key;
        final bucket = entry.value;
        final existing = await _findHistoryRow(dayStart, categoryId, taskId);
        if (existing == null) {
          await into(timerHistoryDaily).insert(
            TimerHistoryDailyCompanion.insert(
              date: dayStart,
              categoryId: categoryId,
              taskId: Value(taskId),
              totalDurationSeconds: bucket.totalSeconds,
              sessionCount: bucket.sessionIds.length,
            ),
          );
        } else {
          await (update(timerHistoryDaily)
                ..where((t) => t.id.equals(existing.id)))
              .write(
            TimerHistoryDailyCompanion(
              totalDurationSeconds:
                  Value(existing.totalDurationSeconds + bucket.totalSeconds),
              sessionCount:
                  Value(existing.sessionCount + bucket.sessionIds.length),
            ),
          );
        }
      }

      // 4. Drop the now-archived interval rows.
      await (delete(timerIntervals)..where((t) => t.id.isIn(archivedIntervalIds)))
          .go();

      // 5. Recompute each touched session's live cache. A session with
      //    nothing left at all is only deleted if it's completed — a
      //    running/paused session must survive as the active session even
      //    once every one of its past intervals has been archived away.
      for (final sessionId in touchedSessionIds) {
        final session = await getSessionById(sessionId);
        if (session == null) continue;
        final remaining =
            await (select(timerIntervals)..where((t) => t.sessionId.equals(sessionId)))
                .get();
        if (session.status == TimerSessionStatus.completed && remaining.isEmpty) {
          await (delete(timerSessions)..where((t) => t.id.equals(sessionId)))
              .go();
          continue;
        }
        final remainingTotal = remaining
            .where((iv) => iv.endedAt != null)
            .fold<int>(0, (sum, iv) => sum + iv.endedAt!.difference(iv.startedAt).inSeconds);
        await (update(timerSessions)..where((t) => t.id.equals(sessionId)))
            .write(TimerSessionsCompanion(totalDurationSeconds: Value(remainingTotal)));
      }
    });
  }

  Future<TimerHistoryDailyRow?> _findHistoryRow(
    DateTime date,
    int categoryId,
    int? taskId,
  ) {
    final query = select(timerHistoryDaily)
      ..where((t) => t.date.equals(date) & t.categoryId.equals(categoryId));
    if (taskId == null) {
      query.where((t) => t.taskId.isNull());
    } else {
      query.where((t) => t.taskId.equals(taskId));
    }
    return query.getSingleOrNull();
  }

  Stream<List<TimerHistoryDailyRow>> watchArchivedDay(DateTime dayStart) {
    return (select(timerHistoryDaily)..where((t) => t.date.equals(dayStart)))
        .watch();
  }

  Stream<List<TimerHistoryDailyRow>> watchHistoryBetween(
    DateTime start,
    DateTime end,
  ) {
    final query = select(timerHistoryDaily)
      ..where(
        (t) =>
            t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      );
    return query.watch();
  }

  Future<void> purgeHistoryOlderThan(DateTime cutoff) {
    return (delete(timerHistoryDaily)..where((t) => t.date.isSmallerThanValue(cutoff)))
        .go();
  }
}
