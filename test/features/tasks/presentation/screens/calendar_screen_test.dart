import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/presentation/screens/calendar_screen.dart';
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

  testWidgets('shows a non-recurring task due today and can mark it done',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final today = DateTime.now();
    await TaskRepositoryImpl(database.taskDao).create(
      title: 'File taxes',
      categoryId: categoryId,
      dueDate: DateTime(today.year, today.month, today.day, 9),
    );

    await tester.pumpWidget(_wrap(database, const CalendarScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('File taxes'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    await _disposeCleanly(tester);
  });

  testWidgets('shows every occurrence of a daily recurring task on the '
      'selected day and skipping one hides only that occurrence',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Health',
      colorValue: 0xFF2F9AC2,
      iconKey: 'health',
    );
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final ruleId = await RecurrenceRuleRepositoryImpl(database.recurrenceRuleDao)
        .create(
      frequency: RecurrenceFrequency.daily,
      startDate: todayDate,
    );
    await TaskRepositoryImpl(database.taskDao).create(
      title: 'Drink water',
      categoryId: categoryId,
      recurrenceRuleId: ruleId,
    );

    await tester.pumpWidget(_wrap(database, const CalendarScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Drink water'), findsOneWidget);
    // Recurring occurrences show a popup menu (skip/reset) instead of a
    // plain delete action.
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Skipped'), findsOneWidget);

    await _disposeCleanly(tester);
  });
}
