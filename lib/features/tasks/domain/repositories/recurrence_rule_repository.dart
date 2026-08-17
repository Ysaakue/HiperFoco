import '../entities/recurrence_frequency.dart';
import '../entities/recurrence_rule.dart';

abstract interface class RecurrenceRuleRepository {
  Future<RecurrenceRule?> getById(int id);

  Future<int> create({
    required RecurrenceFrequency frequency,
    int interval = 1,
    List<int>? byWeekdays,
    int? byMonthDay,
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<void> update(RecurrenceRule rule);

  Future<void> delete(int id);
}
