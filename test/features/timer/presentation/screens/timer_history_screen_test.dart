import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:hiperfoco/features/timer/presentation/screens/timer_history_screen.dart';
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

  testWidgets('shows empty state when there are no sessions today',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const TimerHistoryScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('No focus sessions on this day.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('lists completed sessions for the day, newest first',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final timerRepository = TimerRepositoryImpl(database.timerDao);
    final now = DateTime.now();
    final t0 = DateTime(now.year, now.month, now.day, 9);

    final firstId = await withClock(
      Clock.fixed(t0),
      () => timerRepository.start(categoryId: categoryId),
    );
    await withClock(
      Clock.fixed(t0.add(const Duration(minutes: 10))),
      () => timerRepository.stop(firstId),
    );

    await tester.pumpWidget(_wrap(database, const TimerHistoryScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Work'), findsOneWidget);
    expect(find.textContaining('09:00'), findsOneWidget);
    expect(find.text('0:10:00'), findsOneWidget);

    await _disposeCleanly(tester);
  });
}
