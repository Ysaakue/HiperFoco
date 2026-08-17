import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/recurrence_rule_dao.dart';
import '../../domain/entities/recurrence_frequency.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/repositories/recurrence_rule_repository.dart';

class RecurrenceRuleRepositoryImpl implements RecurrenceRuleRepository {
  RecurrenceRuleRepositoryImpl(this._dao);

  final RecurrenceRuleDao _dao;

  @override
  Future<RecurrenceRule?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create({
    required RecurrenceFrequency frequency,
    int interval = 1,
    List<int>? byWeekdays,
    int? byMonthDay,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    return _dao.insertRule(
      RecurrenceRulesCompanion.insert(
        frequency: frequency,
        interval: Value(interval),
        byWeekdays: Value(_encodeWeekdays(byWeekdays)),
        byMonthDay: Value(byMonthDay),
        startDate: startDate,
        endDate: Value(endDate),
      ),
    );
  }

  @override
  Future<void> update(RecurrenceRule rule) {
    return _dao.updateRule(
      RecurrenceRulesCompanion(
        id: Value(rule.id),
        frequency: Value(rule.frequency),
        interval: Value(rule.interval),
        byWeekdays: Value(_encodeWeekdays(rule.byWeekdays)),
        byMonthDay: Value(rule.byMonthDay),
        startDate: Value(rule.startDate),
        endDate: Value(rule.endDate),
      ),
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteRule(id);

  String? _encodeWeekdays(List<int>? weekdays) =>
      weekdays == null || weekdays.isEmpty ? null : weekdays.join(',');

  List<int>? _decodeWeekdays(String? encoded) =>
      encoded?.split(',').map(int.parse).toList();

  RecurrenceRule _toEntity(RecurrenceRuleRow row) {
    return RecurrenceRule(
      id: row.id,
      frequency: row.frequency,
      interval: row.interval,
      byWeekdays: _decodeWeekdays(row.byWeekdays),
      byMonthDay: row.byMonthDay,
      startDate: row.startDate,
      endDate: row.endDate,
    );
  }
}
