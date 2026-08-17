import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class WatchReminders {
  const WatchReminders(this._repository);

  final ReminderRepository _repository;

  Stream<List<Reminder>> call() => _repository.watchAll();
}
