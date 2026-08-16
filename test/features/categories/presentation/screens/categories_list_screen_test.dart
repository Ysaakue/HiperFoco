import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/presentation/screens/categories_list_screen.dart';
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

/// Drift's query streams schedule a zero-duration cleanup [Timer] when their
/// last listener is cancelled. flutter_test's default teardown unmounts the
/// widget tree (and disposes the ProviderScope) *after* the test body
/// returns, leaving that timer pending and failing the framework's
/// `!timersPending` invariant. Swapping to an empty tree here forces the
/// disposal to happen inside the test body instead, then one more pump
/// drains the resulting timer before the test ends.
Future<void> _disposeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  // `pump()` with no duration never calls FakeAsync.elapse(), so a
  // zero-duration Timer would never actually fire. Duration.zero still
  // triggers elapse() and drains it.
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('shows empty state when there are no categories', (tester) async {
    await tester.pumpWidget(_wrap(database, const CategoriesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No categories yet. Tap + to create one.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('creating a category through the form shows it in the list',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const CategoriesListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Work');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('No categories yet. Tap + to create one.'), findsNothing);

    await _disposeCleanly(tester);
  });

  testWidgets('archiving hides a category and it can be found and unarchived',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const CategoriesListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Work');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('No categories yet. Tap + to create one.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.byIcon(Icons.unarchive_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unarchive'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.unarchive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('No categories yet. Tap + to create one.'), findsNothing);

    await _disposeCleanly(tester);
  });
}
