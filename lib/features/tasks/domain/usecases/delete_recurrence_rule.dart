import '../repositories/recurrence_rule_repository.dart';

class DeleteRecurrenceRule {
  const DeleteRecurrenceRule(this._repository);

  final RecurrenceRuleRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
