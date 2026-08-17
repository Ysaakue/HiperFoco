import '../entities/recurrence_rule.dart';
import '../repositories/recurrence_rule_repository.dart';

class GetRecurrenceRule {
  const GetRecurrenceRule(this._repository);

  final RecurrenceRuleRepository _repository;

  Future<RecurrenceRule?> call(int id) => _repository.getById(id);
}
