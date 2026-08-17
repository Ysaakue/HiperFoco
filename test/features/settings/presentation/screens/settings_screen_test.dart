import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/settings/presentation/providers/settings_providers.dart';
import 'package:hiperfoco/features/settings/presentation/screens/settings_screen.dart';
import 'package:hiperfoco/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:hiperfoco/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(
  AppDatabase database,
  SharedPreferences preferences,
  Widget child,
) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      sharedPreferencesProvider.overrideWithValue(preferences),
    ],
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

Future<int> _seedOldHistoryEntry(AppDatabase database) async {
  final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
    name: 'Work',
    colorValue: 0xFF7C5CFC,
    iconKey: 'work',
  );
  final timerRepository = TimerRepositoryImpl(database.timerDao);
  final longAgo = DateTime(2020, 1, 1, 9);
  final sessionId = await withClock(
    Clock.fixed(longAgo),
    () => timerRepository.start(categoryId: categoryId),
  );
  await withClock(
    Clock.fixed(longAgo.add(const Duration(minutes: 10))),
    () => timerRepository.stop(sessionId),
  );
  await timerRepository.archiveDay(DateTime(2020, 1, 1));
  return categoryId;
}

// A one-shot (non-reactive) count, unlike TimerDao.watchArchivedDay: a fresh
// `.watch()` subscription taken directly against a database instance that's
// also wired into the widget tree via appDatabaseProvider never resolves its
// cleanup during the automated test binding's teardown, hanging the test
// indefinitely instead of failing.
Future<int> _archivedRowCount(AppDatabase database, DateTime day) async {
  final rows = await (database.select(database.timerHistoryDaily)
        ..where((t) => t.date.equals(day)))
      .get();
  return rows.length;
}

void main() {
  late AppDatabase database;
  late SharedPreferences preferences;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() => database.close());

  testWidgets('defaults retention to 6 months and persists a change',
      (tester) async {
    await tester.pumpWidget(_wrap(database, preferences, const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(preferences.getInt('archive.retention_months'), isNull);

    await tester.tap(find.text('12 months'));
    await tester.pumpAndSettle();

    expect(preferences.getInt('archive.retention_months'), 12);

    await _disposeCleanly(tester);
  });

  testWidgets('purge now shows a confirmation dialog and cancelling keeps the data',
      (tester) async {
    await _seedOldHistoryEntry(database);
    final day = DateTime(2020, 1, 1);

    await tester.pumpWidget(_wrap(database, preferences, const SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Purge now'));
    await tester.pumpAndSettle();

    expect(find.text('Purge old data'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await _disposeCleanly(tester);

    expect(await _archivedRowCount(database, day), 1);
  });

  testWidgets('confirming the purge dialog deletes old history and shows a snackbar',
      (tester) async {
    await _seedOldHistoryEntry(database);
    final day = DateTime(2020, 1, 1);

    await tester.pumpWidget(_wrap(database, preferences, const SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Purge now'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Purge now'));
    await tester.pumpAndSettle();

    expect(find.text('Old data purged.'), findsOneWidget);

    await _disposeCleanly(tester);

    expect(await _archivedRowCount(database, day), 0);
  });
}
