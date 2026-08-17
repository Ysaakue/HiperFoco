import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class WatchStandaloneReminders {
  const WatchStandaloneReminders(this._repository);

  final ReminderRepository _repository;

  Stream<List<Reminder>> call() => _repository.watchStandalone();
}
