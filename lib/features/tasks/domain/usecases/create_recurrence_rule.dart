import '../entities/recurrence_frequency.dart';
import '../repositories/recurrence_rule_repository.dart';

class CreateRecurrenceRule {
  const CreateRecurrenceRule(this._repository);

  final RecurrenceRuleRepository _repository;

  Future<int> call({
    required RecurrenceFrequency frequency,
    int interval = 1,
    List<int>? byWeekdays,
    int? byMonthDay,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    return _repository.create(
      frequency: frequency,
      interval: interval,
      byWeekdays: byWeekdays,
      byMonthDay: byMonthDay,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
