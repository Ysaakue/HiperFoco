import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:hiperfoco/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:hiperfoco/l10n/app_localizations.dart';

Widget _wrap(AppDatabase database, Widget child) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Future<void> _disposeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('shows empty state when there is no tracked time this week',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const StatisticsScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('No tracked time for this period yet.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets(
      'shows the total and per-category breakdown for today\'s hot (unarchived) data',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final timerRepository = TimerRepositoryImpl(database.timerDao);
    final now = DateTime.now();
    final t0 = DateTime(now.year, now.month, now.day, 9);

    final id = await withClock(
      Clock.fixed(t0),
      () => timerRepository.start(categoryId: categoryId),
    );
    await withClock(
      Clock.fixed(t0.add(const Duration(minutes: 30))),
      () => timerRepository.stop(id),
    );

    await tester.pumpWidget(_wrap(database, const StatisticsScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('0:30:00'), findsWidgets);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets(
      'combines an already-archived day earlier this week with today\'s hot data',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final timerRepository = TimerRepositoryImpl(database.timerDao);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Monday of the current week — always <= today, so always inside the
    // default Week view regardless of which weekday the test runs on.
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final t0 = weekStart.add(const Duration(hours: 9));
    final archivedId = await withClock(
      Clock.fixed(t0),
      () => timerRepository.start(categoryId: categoryId),
    );
    await withClock(
      Clock.fixed(t0.add(const Duration(minutes: 20))),
      () => timerRepository.stop(archivedId),
    );
    await timerRepository.archiveDay(weekStart);

    // Tracked *after* archiving, so it stays hot even if weekStart == today.
    final t1 = today.add(const Duration(hours: 14));
    final hotId = await withClock(
      Clock.fixed(t1),
      () => timerRepository.start(categoryId: categoryId),
    );
    await withClock(
      Clock.fixed(t1.add(const Duration(minutes: 30))),
      () => timerRepository.stop(hotId),
    );

    await tester.pumpWidget(_wrap(database, const StatisticsScreen()));
    await tester.pump();
    await tester.pump();

    // 20 archived minutes + 30 hot minutes = 50 minutes for the week.
    expect(find.textContaining('0:50:00'), findsWidgets);

    await _disposeCleanly(tester);
  });

  testWidgets('switching to the Day period narrows the total to today only',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final timerRepository = TimerRepositoryImpl(database.timerDao);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final t0 = yesterday.add(const Duration(hours: 9));

    final id = await withClock(
      Clock.fixed(t0),
      () => timerRepository.start(categoryId: categoryId),
    );
    await withClock(
      Clock.fixed(t0.add(const Duration(minutes: 20))),
      () => timerRepository.stop(id),
    );
    await timerRepository.archiveDay(yesterday);

    await tester.pumpWidget(_wrap(database, const StatisticsScreen()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Day'));
    await tester.pump();
    await tester.pump();

    // Yesterday's 20 minutes must not show up once the period is narrowed
    // to today alone, and today has no tracked time in this scenario.
    expect(find.text('No tracked time for this period yet.'), findsOneWidget);

    await _disposeCleanly(tester);
  });
}
