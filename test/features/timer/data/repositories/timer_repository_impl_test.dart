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
}
