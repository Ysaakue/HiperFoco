import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:hiperfoco/features/goals/data/repositories/goal_step_repository_impl.dart';
import 'package:hiperfoco/features/goals/domain/entities/goal.dart';
import 'package:hiperfoco/features/goals/presentation/screens/goal_detail_screen.dart';
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
  late GoalRepositoryImpl goalRepository;
  late GoalStepRepositoryImpl stepRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    goalRepository = GoalRepositoryImpl(database.goalDao);
    stepRepository = GoalStepRepositoryImpl(database.goalStepDao);
  });

  tearDown(() => database.close());

  testWidgets('shows empty state when the goal has no steps', (tester) async {
    final goal = await _createGoal(goalRepository, title: 'Learn Flutter');

    await tester.pumpWidget(_wrap(database, GoalDetailScreen(goal: goal)));
    await tester.pumpAndSettle();

    expect(find.text('No steps yet. Add one below.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('adding a step through the input shows it in the list',
      (tester) async {
    final goal = await _createGoal(goalRepository, title: 'Learn Flutter');

    await tester.pumpWidget(_wrap(database, GoalDetailScreen(goal: goal)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Read the docs');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Read the docs'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('toggling the checkbox marks the step done', (tester) async {
    final goal = await _createGoal(goalRepository, title: 'Learn Flutter');
    await stepRepository.create(goalId: goal.id, title: 'Read the docs');

    await tester.pumpWidget(_wrap(database, GoalDetailScreen(goal: goal)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    await _disposeCleanly(tester);
  });

  testWidgets('promoting a step to a task shows the Promoted badge',
      (tester) async {
    await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final goal = await _createGoal(goalRepository, title: 'Learn Flutter');
    await stepRepository.create(goalId: goal.id, title: 'Read the docs');

    await tester.pumpWidget(_wrap(database, GoalDetailScreen(goal: goal)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.task_alt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(find.text('Promoted'), findsOneWidget);
    expect(find.byIcon(Icons.task_alt_outlined), findsNothing);

    await _disposeCleanly(tester);

    // A one-shot query, not a fresh `.watch()` subscription taken outside
    // the widget tree — see the other tests in this suite for why.
    final tasks = await (database.select(database.tasks)).get();
    expect(tasks.single.title, 'Read the docs');
  });
}

Future<Goal> _createGoal(
  GoalRepositoryImpl repository, {
  required String title,
}) async {
  final id = await repository.create(title: title);
  return (await repository.getById(id))!;
}
