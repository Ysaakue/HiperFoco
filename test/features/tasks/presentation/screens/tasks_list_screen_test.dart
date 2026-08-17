import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/categories/data/repositories/category_repository_impl.dart';
import 'package:hiperfoco/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/task_status.dart';
import 'package:hiperfoco/features/tasks/domain/repositories/notification_scheduler.dart';
import 'package:hiperfoco/features/tasks/presentation/providers/task_providers.dart';
import 'package:hiperfoco/features/tasks/presentation/screens/tasks_list_screen.dart';
import 'package:hiperfoco/l10n/app_localizations.dart';

/// Saving a task resyncs scheduled reminder notifications, which needs a
/// NotificationScheduler — a no-op fake stands in for the
/// flutter_local_notifications-backed one used in the real app.
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

  testWidgets('shows empty state when there are no tasks', (tester) async {
    await tester.pumpWidget(_wrap(database, const TasksListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet. Tap + to create one.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('creating a task through the form shows it in the list',
      (tester) async {
    await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );

    await tester.pumpWidget(_wrap(database, const TasksListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Write report');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('No tasks yet. Tap + to create one.'), findsNothing);

    await _disposeCleanly(tester);
  });

  testWidgets('creating a task with Repeat enabled shows the recurring icon',
      (tester) async {
    // Enabling Repeat expands the form well past the default test surface's
    // height, and ListView only builds children within its viewport/cache
    // extent — a widget the ListView hasn't built yet doesn't exist as an
    // Element, so ensureVisible/scrollUntilVisible have nothing to scroll
    // to. A taller surface sidesteps that entirely by fitting the whole
    // form on screen at once.
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Health',
      colorValue: 0xFF2F9AC2,
      iconKey: 'health',
    );

    await tester.pumpWidget(_wrap(database, const TasksListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Drink water');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Health').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Drink water'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('toggling the checkbox marks the task completed', (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final taskDao = database.taskDao;
    await taskDao.insertTask(
      TasksCompanion.insert(title: 'Existing task', categoryId: categoryId),
    );

    await tester.pumpWidget(_wrap(database, const TasksListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    await _disposeCleanly(tester);
  });

  testWidgets('hiding completed tasks filters them out and can be reverted',
      (tester) async {
    final categoryId = await CategoryRepositoryImpl(database.categoryDao).create(
      name: 'Work',
      colorValue: 0xFF7C5CFC,
      iconKey: 'work',
    );
    final taskRepository = TaskRepositoryImpl(database.taskDao);
    await taskRepository.create(title: 'Pending task', categoryId: categoryId);
    final doneId =
        await taskRepository.create(title: 'Done task', categoryId: categoryId);
    await taskRepository.setStatus(doneId, TaskStatus.completed);

    await tester.pumpWidget(_wrap(database, const TasksListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Pending task'), findsOneWidget);
    expect(find.text('Done task'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pending task'), findsOneWidget);
    expect(find.text('Done task'), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Done task'), findsOneWidget);

    await _disposeCleanly(tester);
  });
}
