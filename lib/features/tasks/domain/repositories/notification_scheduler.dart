/// Domain-facing abstraction over the OS notification API, so
/// [ReminderSchedulingService] can depend on an interface instead of the
/// concrete `flutter_local_notifications`-backed implementation.
abstract interface class NotificationScheduler {
  Future<void> cancelAll();

  Future<void> schedule({
    required int id,
    required String title,
    String? body,
    required DateTime scheduledAt,
  });
}
