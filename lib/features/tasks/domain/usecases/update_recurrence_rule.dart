import '../entities/recurrence_rule.dart';
import '../repositories/recurrence_rule_repository.dart';

class UpdateRecurrenceRule {
  const UpdateRecurrenceRule(this._repository);

  final RecurrenceRuleRepository _repository;

  Future<void> call(RecurrenceRule rule) => _repository.update(rule);
}
