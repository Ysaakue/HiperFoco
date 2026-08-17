import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_history_entry.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_interval.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_session.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_session_status.dart';
import 'package:hiperfoco/features/timer/domain/repositories/timer_repository.dart';
import 'package:hiperfoco/features/timer/domain/usecases/pause_timer.dart';
import 'package:hiperfoco/features/timer/domain/usecases/purge_old_data.dart';
import 'package:hiperfoco/features/timer/domain/usecases/resume_timer.dart';
import 'package:hiperfoco/features/timer/domain/usecases/start_timer.dart';
import 'package:hiperfoco/features/timer/domain/usecases/stop_timer.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_active_session.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_archived_between.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_archived_day.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_intervals_for_day.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_today_category_duration.dart';
import 'package:hiperfoco/features/timer/domain/usecases/watch_today_total_duration.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

void main() {
  late MockTimerRepository repository;

  final session = TimerSession(
    id: 1,
    categoryId: 10,
    status: TimerSessionStatus.running,
    startedAt: DateTime(2026, 1, 1, 9),
    totalDurationSeconds: 0,
    currentIntervalStartedAt: DateTime(2026, 1, 1, 9),
  );

  setUp(() {
    repository = MockTimerRepository();
  });

  group('StartTimer', () {
    test('delegates to repository.start with the given fields', () async {
      when(() => repository.start(categoryId: 10, taskId: 5))
          .thenAnswer((_) async => 1);

      final id = await StartTimer(repository)(categoryId: 10, taskId: 5);

      expect(id, 1);
      verify(() => repository.start(categoryId: 10, taskId: 5)).called(1);
    });
  });

  group('PauseTimer', () {
    test('delegates to repository.pause', () async {
      when(() => repository.pause(1)).thenAnswer((_) async {});

      await PauseTimer(repository)(1);

      verify(() => repository.pause(1)).called(1);
    });
  });

  group('ResumeTimer', () {
    test('delegates to repository.resume', () async {
      when(() => repository.resume(1)).thenAnswer((_) async {});

      await ResumeTimer(repository)(1);

      verify(() => repository.resume(1)).called(1);
    });
  });

  group('StopTimer', () {
    test('delegates to repository.stop', () async {
      when(() => repository.stop(1)).thenAnswer((_) async {});

      await StopTimer(repository)(1);

      verify(() => repository.stop(1)).called(1);
    });
  });

  group('WatchActiveSession', () {
    test('delegates to repository.watchActiveSession', () {
      when(() => repository.watchActiveSession())
          .thenAnswer((_) => Stream.value(session));

      final stream = WatchActiveSession(repository)();

      expect(stream, emits(session));
      verify(() => repository.watchActiveSession()).called(1);
    });
  });

  group('WatchTodayCategoryDuration', () {
    test('delegates to repository.watchTodayDurationSecondsForCategory', () {
      when(() => repository.watchTodayDurationSecondsForCategory(10))
          .thenAnswer((_) => Stream.value(120));

      final stream = WatchTodayCategoryDuration(repository)(10);

      expect(stream, emits(120));
      verify(() => repository.watchTodayDurationSecondsForCategory(10))
          .called(1);
    });
  });

  group('WatchTodayTotalDuration', () {
    test('delegates to repository.watchTodayTotalDurationSeconds', () {
      when(() => repository.watchTodayTotalDurationSeconds())
          .thenAnswer((_) => Stream.value(300));

      final stream = WatchTodayTotalDuration(repository)();

      expect(stream, emits(300));
      verify(() => repository.watchTodayTotalDurationSeconds()).called(1);
    });
  });

  group('WatchIntervalsForDay', () {
    test('delegates to repository.watchIntervalsForDay', () {
      final day = DateTime(2026, 1, 1);
      final interval = TimerInterval(
        id: 1,
        sessionId: 1,
        categoryId: 10,
        startedAt: DateTime(2026, 1, 1, 9),
        endedAt: DateTime(2026, 1, 1, 9, 30),
      );
      when(() => repository.watchIntervalsForDay(day))
          .thenAnswer((_) => Stream.value([interval]));

      final stream = WatchIntervalsForDay(repository)(day);

      expect(stream, emits([interval]));
      verify(() => repository.watchIntervalsForDay(day)).called(1);
    });
  });

  group('WatchArchivedDay', () {
    test('delegates to repository.watchArchivedDay', () {
      final day = DateTime(2026, 1, 1);
      final entry = TimerHistoryEntry(
        date: day,
        categoryId: 10,
        totalDurationSeconds: 600,
        sessionCount: 2,
      );
      when(() => repository.watchArchivedDay(day))
          .thenAnswer((_) => Stream.value([entry]));

      final stream = WatchArchivedDay(repository)(day);

      expect(stream, emits([entry]));
      verify(() => repository.watchArchivedDay(day)).called(1);
    });
  });

  group('WatchArchivedBetween', () {
    test('delegates to repository.watchArchivedBetween', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 8);
      final entry = TimerHistoryEntry(
        date: start,
        categoryId: 10,
        totalDurationSeconds: 600,
        sessionCount: 2,
      );
      when(() => repository.watchArchivedBetween(start, end))
          .thenAnswer((_) => Stream.value([entry]));

      final stream = WatchArchivedBetween(repository)(start, end);

      expect(stream, emits([entry]));
      verify(() => repository.watchArchivedBetween(start, end)).called(1);
    });
  });

  group('PurgeOldData', () {
    test('delegates to repository.purgeHistoryOlderThan', () async {
      when(() => repository.purgeHistoryOlderThan(6)).thenAnswer((_) async {});

      await PurgeOldData(repository)(olderThanMonths: 6);

      verify(() => repository.purgeHistoryOlderThan(6)).called(1);
    });
  });
}
