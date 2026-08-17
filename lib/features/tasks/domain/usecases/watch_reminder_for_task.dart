import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class WatchReminderForTask {
  const WatchReminderForTask(this._repository);

  final ReminderRepository _repository;

  Stream<Reminder?> call(int taskId) => _repository.watchForTask(taskId);
}
