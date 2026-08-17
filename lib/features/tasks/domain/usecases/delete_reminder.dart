import '../repositories/reminder_repository.dart';

class DeleteReminder {
  const DeleteReminder(this._repository);

  final ReminderRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
