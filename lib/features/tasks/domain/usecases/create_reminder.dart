import '../repositories/reminder_repository.dart';

class CreateReminder {
  const CreateReminder(this._repository);

  final ReminderRepository _repository;

  Future<int> call({
    int? taskId,
    int? recurrenceRuleId,
    DateTime? scheduledAt,
    int offsetMinutes = 0,
    String? message,
    bool isEnabled = true,
  }) {
    return _repository.create(
      taskId: taskId,
      recurrenceRuleId: recurrenceRuleId,
      scheduledAt: scheduledAt,
      offsetMinutes: offsetMinutes,
      message: message,
      isEnabled: isEnabled,
    );
  }
}
