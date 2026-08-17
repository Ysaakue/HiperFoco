import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/tasks/presentation/providers/task_providers.dart';
import 'features/timer/presentation/providers/timer_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  final notificationService =
      NotificationService(FlutterLocalNotificationsPlugin());
  await notificationService.initialize();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      notificationSchedulerProvider.overrideWithValue(notificationService),
    ],
  );

  // Archive any days that elapsed while the app was closed (and purge
  // anything past the retention window) before the UI ever renders, so the
  // "today is hot, everything before is compacted" invariant always holds
  // by the time a screen can be shown.
  await container.read(dailyArchiveServiceProvider).run();

  // Resync every enabled reminder's next scheduled notification the same
  // way — cheap, idempotent, and keeps schedules correct even if reminders
  // were edited while the app was closed (not possible today, but keeps the
  // invariant simple regardless).
  await container.read(reminderSchedulingServiceProvider).run();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HiperFocoApp(),
    ),
  );
}
