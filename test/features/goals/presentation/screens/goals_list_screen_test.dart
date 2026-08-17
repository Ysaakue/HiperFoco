import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/goals/presentation/screens/goals_list_screen.dart';
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

  testWidgets('shows empty state when there are no goals', (tester) async {
    await tester.pumpWidget(_wrap(database, const GoalsListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No goals yet. Tap + to create one.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('creating a goal through the form shows it in the list',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const GoalsListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Learn Flutter');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Learn Flutter'), findsOneWidget);
    expect(find.text('No goals yet. Tap + to create one.'), findsNothing);

    await _disposeCleanly(tester);
  });

  testWidgets('shows step progress once a goal has steps', (tester) async {
    final goalId =
        await GoalRepositoryImpl(database.goalDao).create(title: 'Learn Flutter');
    final stepRepository = GoalStepRepositoryImpl(database.goalStepDao);
    final firstStepId =
        await stepRepository.create(goalId: goalId, title: 'Read the docs');
    await stepRepository.create(goalId: goalId, title: 'Build a todo app');
    await stepRepository.setDone(firstStepId, true);

    await tester.pumpWidget(_wrap(database, const GoalsListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('deleting a goal removes it and its steps', (tester) async {
    final goalId =
        await GoalRepositoryImpl(database.goalDao).create(title: 'Learn Flutter');
    final stepRepository = GoalStepRepositoryImpl(database.goalStepDao);
    await stepRepository.create(goalId: goalId, title: 'Read the docs');

    await tester.pumpWidget(_wrap(database, const GoalsListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No goals yet. Tap + to create one.'), findsOneWidget);

    await _disposeCleanly(tester);

    // A one-shot query, not `.watchForGoal(...).first` — a fresh `.watch()`
    // subscription taken outside the widget tree inside a `testWidgets`
    // hangs the test's teardown indefinitely instead of failing (see the
    // M3 QA doc's TC-08 for the full story behind this lesson).
    final remaining = await (database.select(database.goalSteps)
          ..where((t) => t.goalId.equals(goalId)))
        .get();
    expect(remaining, isEmpty);
  });
}
