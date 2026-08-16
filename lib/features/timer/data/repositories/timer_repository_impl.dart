import 'package:clock/clock.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/timer_dao.dart';
import '../../domain/entities/timer_interval.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/repositories/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  TimerRepositoryImpl(this._dao);

  final TimerDao _dao;

  @override
  Stream<TimerSession?> watchActiveSession() {
    return _dao.watchActiveSession().map((row) => row == null ? null : _toEntity(row));
  }

  @override
  Future<int> start({required int categoryId, int? taskId}) {
    return _dao.startSession(categoryId: categoryId, taskId: taskId);
  }

  @override
  Future<void> pause(int sessionId) => _dao.pauseSession(sessionId);

  @override
  Future<void> resume(int sessionId) => _dao.resumeSession(sessionId);

  @override
  Future<void> stop(int sessionId) => _dao.stopSession(sessionId);

  @override
  Stream<int> watchTodayDurationSecondsForCategory(int categoryId) {
    final (start, end) = _todayRange();
    return _dao.watchTotalClosedSecondsForCategoryBetween(categoryId, start, end);
  }

  @override
  Stream<int> watchTodayTotalDurationSeconds() {
    final (start, end) = _todayRange();
    return _dao.watchTotalClosedSecondsBetween(start, end);
  }

  @override
  Stream<List<TimerInterval>> watchIntervalsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _dao.watchIntervalsForDay(start, end).map(
          (rows) => [
            for (final row in rows)
              TimerInterval(
                id: row.interval.id,
                sessionId: row.interval.sessionId,
                categoryId: row.categoryId,
                taskId: row.taskId,
                startedAt: row.interval.startedAt,
                endedAt: row.interval.endedAt,
              ),
          ],
        );
  }

  @override
  Future<int?> categoryIdForSession(int sessionId) async {
    final session = await _dao.getSessionById(sessionId);
    return session?.categoryId;
  }

  (DateTime, DateTime) _todayRange() {
    final now = clock.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (start, end);
  }

  TimerSession _toEntity(TimerSessionRow row) {
    return TimerSession(
      id: row.id,
      taskId: row.taskId,
      categoryId: row.categoryId,
      status: row.status,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      totalDurationSeconds: row.totalDurationSeconds,
      currentIntervalStartedAt: row.currentIntervalStartedAt,
    );
  }
}
