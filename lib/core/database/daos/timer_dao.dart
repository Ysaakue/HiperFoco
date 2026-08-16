import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../../features/timer/domain/entities/timer_session_status.dart';
import '../app_database.dart';
import '../tables/timer_intervals_table.dart';
import '../tables/timer_sessions_table.dart';

part 'timer_dao.g.dart';

@DriftAccessor(tables: [TimerSessions, TimerIntervals])
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
}
