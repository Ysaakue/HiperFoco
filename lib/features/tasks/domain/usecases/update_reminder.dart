import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class UpdateReminder {
  const UpdateReminder(this._repository);

  final ReminderRepository _repository;

  Future<void> call(Reminder reminder) => _repository.update(reminder);
}
