import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_session_status.dart';
import 'package:hiperfoco/features/timer/presentation/screens/timer_screen.dart';
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

/// See categories_list_screen_test.dart for why this is necessary: Drift's
/// query-stream cancellation schedules a zero-duration Timer that must be
/// drained before the test ends, and TimerScreen additionally owns a
/// real Timer.periodic ticker that must be cancelled (via dispose) first.
/// pumpAndSettle() is deliberately avoided throughout this file because a
/// periodic timer never "settles".
Future<void> _disposeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase database;
  late int categoryId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
  });

  tearDown(() => database.close());

  testWidgets('shows the running session and can pause, resume and stop',
      (tester) async {
    final timerRepository = TimerRepositoryImpl(database.timerDao);
    final sessionId = await timerRepository.start(categoryId: categoryId);

    await tester.pumpWidget(_wrap(database, const TimerScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Focusing'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    var session = await database.timerDao.getSessionById(sessionId);
    expect(session!.status, TimerSessionStatus.paused);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump();

    expect(find.text('Focusing'), findsOneWidget);
    session = await database.timerDao.getSessionById(sessionId);
    expect(session!.status, TimerSessionStatus.running);

    await tester.tap(find.byIcon(Icons.stop_circle_outlined));
    await tester.pump();
    await tester.pump();

    session = await database.timerDao.getSessionById(sessionId);
    expect(session!.status, TimerSessionStatus.completed);

    await _disposeCleanly(tester);
  });
}
