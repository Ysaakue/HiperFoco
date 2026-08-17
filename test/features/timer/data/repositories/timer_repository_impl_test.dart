import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_session_status.dart';

Future<T> at<T>(DateTime time, Future<T> Function() action) =>
    withClock(Clock.fixed(time), action);

void main() {
  late AppDatabase database;
  late TimerRepositoryImpl repository;
  late int categoryId;
  late int otherCategoryId;

  final t0 = DateTime(2026, 3, 10, 9); // a Tuesday, well inside its own day

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TimerRepositoryImpl(database.timerDao);
    final categoryRepository = CategoryRepositoryImpl(database.categoryDao);
    categoryId = await categoryRepository.create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    otherCategoryId = await categoryRepository.create(
      name: 'Study',
      colorValue: 0xFF2F9AC2,
      iconKey: 'study',
    );
  });

  tearDown(() => database.close());

  test('start creates a running session with an open interval', () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));

    final session = await repository.watchActiveSession().first;

    expect(session, isNotNull);
    expect(session!.id, id);
    expect(session.categoryId, categoryId);
    expect(session.status, TimerSessionStatus.running);
    expect(session.startedAt, t0);
    expect(session.currentIntervalStartedAt, t0);
    expect(session.totalDurationSeconds, 0);
  });

  test('pause closes the open interval and accumulates duration', () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));

    await at(t0.add(const Duration(minutes: 5)), () => repository.pause(id));

    final session = await repository.watchActiveSession().first;
    expect(session!.status, TimerSessionStatus.paused);
    expect(session.totalDurationSeconds, const Duration(minutes: 5).inSeconds);
    expect(session.currentIntervalStartedAt, isNull);
  });

  test('resume opens a new interval without losing accumulated duration',
      () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));
    await at(t0.add(const Duration(minutes: 5)), () => repository.pause(id));

    // 2 minutes pass while paused; that gap must not be counted.
    final resumedAt = t0.add(const Duration(minutes: 7));
    await at(resumedAt, () => repository.resume(id));

    var session = await repository.watchActiveSession().first;
    expect(session!.status, TimerSessionStatus.running);
    expect(session.currentIntervalStartedAt, resumedAt);
    expect(session.totalDurationSeconds, const Duration(minutes: 5).inSeconds);

    await at(
      resumedAt.add(const Duration(minutes: 3)),
      () => repository.stop(id),
    );

    session = await repository.watchActiveSession().first;
    expect(session, isNull); // stopped sessions are no longer "active"

    final today = await at(
      t0,
      () => repository.watchTodayDurationSecondsForCategory(categoryId).first,
    );
    expect(today, const Duration(minutes: 8).inSeconds); // 5 + 3, not 10
  });

  test('stop closes the open interval and marks the session completed',
      () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));

    final stoppedAt = t0.add(const Duration(minutes: 12));
    await at(stoppedAt, () => repository.stop(id));

    final session = await database.timerDao.getSessionById(id);
    expect(session!.status, TimerSessionStatus.completed);
    expect(session.completedAt, stoppedAt);
    expect(session.currentIntervalStartedAt, isNull);
    expect(session.totalDurationSeconds, const Duration(minutes: 12).inSeconds);
  });

  test(
      'starting a new session stops whatever was previously active, '
      'leaving only one active session at a time', () async {
    final firstId =
        await at(t0, () => repository.start(categoryId: categoryId));

    final switchedAt = t0.add(const Duration(minutes: 4));
    final secondId = await at(
      switchedAt,
      () => repository.start(categoryId: otherCategoryId),
    );

    final firstSession = await database.timerDao.getSessionById(firstId);
    expect(firstSession!.status, TimerSessionStatus.completed);
    expect(firstSession.totalDurationSeconds, const Duration(minutes: 4).inSeconds);

    final active = await repository.watchActiveSession().first;
    expect(active!.id, secondId);
    expect(active.categoryId, otherCategoryId);
    expect(active.status, TimerSessionStatus.running);
  });

  test('starting a new session also stops a paused session', () async {
    final firstId =
        await at(t0, () => repository.start(categoryId: categoryId));
    await at(
      t0.add(const Duration(minutes: 2)),
      () => repository.pause(firstId),
    );

    await at(
      t0.add(const Duration(minutes: 10)),
      () => repository.start(categoryId: otherCategoryId),
    );

    final firstSession = await database.timerDao.getSessionById(firstId);
    expect(firstSession!.status, TimerSessionStatus.completed);
    // Only the 2 minutes while it was actually running should count, not
    // the time it spent paused.
    expect(firstSession.totalDurationSeconds, const Duration(minutes: 2).inSeconds);
  });

  test('watchTodayDurationSecondsForCategory only counts closed intervals '
      'started today', () async {
    // Yesterday: should not count toward today's total.
    final yesterday = t0.subtract(const Duration(days: 1));
    final oldId =
        await at(yesterday, () => repository.start(categoryId: categoryId));
    await at(
      yesterday.add(const Duration(minutes: 20)),
      () => repository.stop(oldId),
    );

    final todayId =
        await at(t0, () => repository.start(categoryId: categoryId));
    await at(
      t0.add(const Duration(minutes: 6)),
      () => repository.stop(todayId),
    );

    final todayCategorySeconds = await at(
      t0,
      () => repository.watchTodayDurationSecondsForCategory(categoryId).first,
    );
    final todayTotalSeconds = await at(
      t0,
      () => repository.watchTodayTotalDurationSeconds().first,
    );

    expect(todayCategorySeconds, const Duration(minutes: 6).inSeconds);
    expect(todayTotalSeconds, const Duration(minutes: 6).inSeconds);
  });

  test('watchIntervalsForDay returns the day\'s intervals oldest first with '
      'the category attached', () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));
    await at(t0.add(const Duration(minutes: 5)), () => repository.pause(id));
    await at(
      t0.add(const Duration(minutes: 8)),
      () => repository.resume(id),
    );
    await at(
      t0.add(const Duration(minutes: 15)),
      () => repository.stop(id),
    );

    final intervals = await repository.watchIntervalsForDay(t0).first;

    expect(intervals, hasLength(2));
    expect(intervals[0].categoryId, categoryId);
    expect(intervals[0].startedAt, t0);
    expect(intervals[0].endedAt, t0.add(const Duration(minutes: 5)));
    expect(intervals[1].startedAt, t0.add(const Duration(minutes: 8)));
    expect(intervals[1].endedAt, t0.add(const Duration(minutes: 15)));
  });

  test('categoryIdForSession returns the owning category', () async {
    final id = await at(t0, () => repository.start(categoryId: categoryId));

    final result = await repository.categoryIdForSession(id);

    expect(result, categoryId);
  });

  group('archiveDay', () {
    test('compacts closed intervals into history and deletes source rows',
        () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 10)), () => repository.stop(id));

      final day = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day);

      final archived = await repository.watchArchivedDay(day).first;
      expect(archived, hasLength(1));
      expect(archived.single.categoryId, categoryId);
      expect(
        archived.single.totalDurationSeconds,
        const Duration(minutes: 10).inSeconds,
      );
      expect(archived.single.sessionCount, 1);

      final remainingIntervals = await repository.watchIntervalsForDay(day).first;
      expect(remainingIntervals, isEmpty);
    });

    test('groups separate categories on the same day into separate buckets',
        () async {
      final id1 = await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 5)), () => repository.stop(id1));
      final id2 = await at(
        t0.add(const Duration(minutes: 6)),
        () => repository.start(categoryId: otherCategoryId),
      );
      await at(t0.add(const Duration(minutes: 16)), () => repository.stop(id2));

      final day = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day);

      final archived = await repository.watchArchivedDay(day).first;
      expect(archived, hasLength(2));
      final byCategory = {for (final e in archived) e.categoryId: e};
      expect(
        byCategory[categoryId]!.totalDurationSeconds,
        const Duration(minutes: 5).inSeconds,
      );
      expect(
        byCategory[otherCategoryId]!.totalDurationSeconds,
        const Duration(minutes: 10).inSeconds,
      );
    });

    test(
        'groups sessions with a task into a bucket separate from '
        'task-less sessions in the same category', () async {
      const taskId = 42;
      final withTaskId = await at(
        t0,
        () => repository.start(categoryId: categoryId, taskId: taskId),
      );
      await at(
        t0.add(const Duration(minutes: 5)),
        () => repository.stop(withTaskId),
      );
      final withoutTaskId = await at(
        t0.add(const Duration(minutes: 6)),
        () => repository.start(categoryId: categoryId),
      );
      await at(
        t0.add(const Duration(minutes: 16)),
        () => repository.stop(withoutTaskId),
      );

      final day = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day);

      final archived = await repository.watchArchivedDay(day).first;
      expect(archived, hasLength(2));
      final byTaskId = {for (final e in archived) e.taskId: e};
      expect(
        byTaskId[taskId]!.totalDurationSeconds,
        const Duration(minutes: 5).inSeconds,
      );
      expect(
        byTaskId[null]!.totalDurationSeconds,
        const Duration(minutes: 10).inSeconds,
      );
    });

    test('is idempotent: re-archiving a day with nothing new left does not '
        'duplicate totals', () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 10)), () => repository.stop(id));

      final day = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day);
      await repository.archiveDay(day);

      final archived = await repository.watchArchivedDay(day).first;
      expect(archived, hasLength(1));
      expect(
        archived.single.totalDurationSeconds,
        const Duration(minutes: 10).inSeconds,
      );
    });

    test(
        'archiving the same (day, category, task) bucket twice adds to the '
        'existing history row instead of overwriting or duplicating it',
        () async {
      final day = DateTime(t0.year, t0.month, t0.day);

      final firstId = await at(t0, () => repository.start(categoryId: categoryId));
      await at(
        t0.add(const Duration(minutes: 10)),
        () => repository.stop(firstId),
      );
      await repository.archiveDay(day);

      final secondId = await at(
        t0.add(const Duration(hours: 1)),
        () => repository.start(categoryId: categoryId),
      );
      await at(
        t0.add(const Duration(hours: 1, minutes: 5)),
        () => repository.stop(secondId),
      );
      await repository.archiveDay(day);

      final archived = await repository.watchArchivedDay(day).first;
      expect(archived, hasLength(1));
      expect(
        archived.single.totalDurationSeconds,
        const Duration(minutes: 15).inSeconds,
      );
      expect(archived.single.sessionCount, 2);
    });

    test(
        'splits a session left running across midnight, keeping it alive '
        'on the new day', () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));

      final day0 = DateTime(t0.year, t0.month, t0.day);
      final day1 = day0.add(const Duration(days: 1));
      await repository.archiveDay(day0);

      // day0's portion (09:00 -> midnight = 15h) is archived.
      final archived = await repository.watchArchivedDay(day0).first;
      expect(archived, hasLength(1));
      expect(
        archived.single.totalDurationSeconds,
        const Duration(hours: 15).inSeconds,
      );

      // The session is still running, continuing from midnight.
      final session = await database.timerDao.getSessionById(id);
      expect(session!.status, TimerSessionStatus.running);
      expect(session.currentIntervalStartedAt, day1);
      expect(session.totalDurationSeconds, 0); // nothing un-archived left

      final elapsedToday = await at(
        day1.add(const Duration(hours: 1)),
        () => repository.watchTodayDurationSecondsForCategory(categoryId).first,
      );
      expect(elapsedToday, 0); // still open, so not part of the closed total
    });

    test('catches up a session left running for multiple days, one '
        'archiveDay call per day', () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));

      final day0 = DateTime(t0.year, t0.month, t0.day);
      final day1 = day0.add(const Duration(days: 1));
      final day2 = day0.add(const Duration(days: 2));
      final day3 = day0.add(const Duration(days: 3));

      await repository.archiveDay(day0);
      await repository.archiveDay(day1);
      await repository.archiveDay(day2);

      final archivedDay0 = await repository.watchArchivedDay(day0).first;
      final archivedDay1 = await repository.watchArchivedDay(day1).first;
      final archivedDay2 = await repository.watchArchivedDay(day2).first;

      expect(
        archivedDay0.single.totalDurationSeconds,
        const Duration(hours: 15).inSeconds,
      );
      expect(
        archivedDay1.single.totalDurationSeconds,
        const Duration(hours: 24).inSeconds,
      );
      expect(
        archivedDay2.single.totalDurationSeconds,
        const Duration(hours: 24).inSeconds,
      );

      final session = await database.timerDao.getSessionById(id);
      expect(session!.status, TimerSessionStatus.running);
      expect(session.currentIntervalStartedAt, day3);
    });

    test('archiving a day with a paused session keeps the session row alive',
        () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 30)), () => repository.pause(id));

      final day0 = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day0);

      final archived = await repository.watchArchivedDay(day0).first;
      expect(
        archived.single.totalDurationSeconds,
        const Duration(minutes: 30).inSeconds,
      );

      // The paused session must survive so the user can resume it later.
      final session = await database.timerDao.getSessionById(id);
      expect(session, isNotNull);
      expect(session!.status, TimerSessionStatus.paused);
      expect(session.totalDurationSeconds, 0);

      final active = await repository.watchActiveSession().first;
      expect(active!.id, id);
    });

    test('deletes a completed session once its history is fully archived',
        () async {
      final id = await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 20)), () => repository.stop(id));

      final day0 = DateTime(t0.year, t0.month, t0.day);
      await repository.archiveDay(day0);

      final session = await database.timerDao.getSessionById(id);
      expect(session, isNull);
    });

    test('does not touch data outside the archived day', () async {
      final todayId =
          await at(t0, () => repository.start(categoryId: categoryId));
      await at(t0.add(const Duration(minutes: 5)), () => repository.stop(todayId));

      final day0 = DateTime(t0.year, t0.month, t0.day);
      final yesterday = day0.subtract(const Duration(days: 1));
      await repository.archiveDay(yesterday);

      final archivedYesterday = await repository.watchArchivedDay(yesterday).first;
      expect(archivedYesterday, isEmpty);

      final todayIntervals = await repository.watchIntervalsForDay(day0).first;
      expect(todayIntervals, hasLength(1));
    });
  });

  group('purgeHistoryOlderThan', () {
    test('deletes archived entries older than the cutoff, keeps newer ones',
        () async {
      final oldDay = DateTime(2025, 1, 15);
      final recentDay = DateTime(2026, 2, 15);

      for (final day in [oldDay, recentDay]) {
        final id = await at(
          day.add(const Duration(hours: 9)),
          () => repository.start(categoryId: categoryId),
        );
        await at(
          day.add(const Duration(hours: 9, minutes: 10)),
          () => repository.stop(id),
        );
        await repository.archiveDay(day);
      }

      // "Now" is 2026-03-10; 6 months of retention keeps everything from
      // 2025-09-10 onward.
      await at(DateTime(2026, 3, 10), () => repository.purgeHistoryOlderThan(6));

      expect(await repository.watchArchivedDay(oldDay).first, isEmpty);
      expect(await repository.watchArchivedDay(recentDay).first, isNotEmpty);
    });

    test('handles short-month boundaries (28/30/31-day months) consistently',
        () async {
      // "Now" = 2026-03-31 (31-day March). 6 months back normalizes to
      // 2025-09-30 (September only has 30 days) via Dart's DateTime
      // rollover instead of throwing or silently miscounting.
      final now = DateTime(2026, 3, 31);
      final justInsideCutoff = DateTime(2025, 9, 30, 12);
      final justOutsideCutoff = DateTime(2025, 9, 29, 12);

      for (final day in [justInsideCutoff, justOutsideCutoff]) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        final id = await at(day, () => repository.start(categoryId: categoryId));
        await at(
          day.add(const Duration(minutes: 10)),
          () => repository.stop(id),
        );
        await repository.archiveDay(normalizedDay);
      }

      await at(now, () => repository.purgeHistoryOlderThan(6));

      expect(
        await repository.watchArchivedDay(DateTime(2025, 9, 30)).first,
        isNotEmpty,
      );
      expect(
        await repository.watchArchivedDay(DateTime(2025, 9, 29)).first,
        isEmpty,
      );
    });
  });
}
