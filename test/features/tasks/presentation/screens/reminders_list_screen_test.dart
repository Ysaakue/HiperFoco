import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/notification_scheduler.dart';
import 'package:hiperfoco/features/tasks/presentation/providers/task_providers.dart';
import 'package:hiperfoco/features/tasks/presentation/screens/reminders_list_screen.dart';
import 'package:hiperfoco/l10n/app_localizations.dart';

class _NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    String? body,
    required DateTime scheduledAt,
  }) async {}
}

Widget _wrap(AppDatabase database, Widget child) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      notificationSchedulerProvider.overrideWithValue(_NoopNotificationScheduler()),
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

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('shows empty state when there are no reminders', (tester) async {
    await tester.pumpWidget(_wrap(database, const RemindersListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No reminders yet. Tap + to create one.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('creating a one-time standalone reminder shows it in the list',
      (tester) async {
    await tester.pumpWidget(_wrap(database, const RemindersListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Take out the trash');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Take out the trash'), findsOneWidget);
    expect(find.text('No reminders yet. Tap + to create one.'), findsNothing);

    await _disposeCleanly(tester);
  });
}
