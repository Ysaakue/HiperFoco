import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recurrence_rules_table.dart';

part 'recurrence_rule_dao.g.dart';

@DriftAccessor(tables: [RecurrenceRules])
class RecurrenceRuleDao extends DatabaseAccessor<AppDatabase>
    with _$RecurrenceRuleDaoMixin {
  RecurrenceRuleDao(super.db);

  Future<RecurrenceRuleRow?> getById(int id) =>
      (select(recurrenceRules)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertRule(RecurrenceRulesCompanion entry) =>
      into(recurrenceRules).insert(entry);

  Future<bool> updateRule(RecurrenceRulesCompanion entry) =>
      update(recurrenceRules).replace(entry);

  Future<int> deleteRule(int id) =>
      (delete(recurrenceRules)..where((t) => t.id.equals(id))).go();
}
