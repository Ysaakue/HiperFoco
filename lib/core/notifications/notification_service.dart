import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/tasks/domain/repositories/notification_scheduler.dart';

/// Thin wrapper around `flutter_local_notifications`: local scheduling only,
/// no server involved. Reminders are inherently local-only, matching the
/// rest of the app's "100% local storage" design.
class NotificationService implements NotificationScheduler {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'reminders';
  static const _channelName = 'Reminders';
  static const _channelDescription = 'Task and standalone reminders';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Requests the runtime notification permission (Android 13+). A no-op
  /// returning true on older Android versions, where the permission is
  /// granted at install time.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Schedules a single notification at [scheduledAt]. Using
  /// [AndroidScheduleMode.inexactAllowWhileIdle] deliberately: reminders
  /// don't need second-level precision, and avoiding the exact-alarm APIs
  /// sidesteps their extra permission/Play Store scrutiny.
  @override
  Future<void> schedule({
    required int id,
    required String title,
    String? body,
    required DateTime scheduledAt,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
