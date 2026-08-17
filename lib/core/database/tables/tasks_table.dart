import 'package:drift/drift.dart';

import '../../../features/tasks/domain/entities/task_status.dart';
import 'categories_table.dart';
import 'recurrence_rules_table.dart';

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  TextColumn get status => textEnum<TaskStatus>()
      .withDefault(Constant(TaskStatus.pending.name))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Recurrence is virtual: this only points at the rule used to compute
  /// occurrences on demand. No per-occurrence row is ever stored for the
  /// task itself — see [TaskOccurrenceOverrides] for the exceptions.
  IntColumn get recurrenceRuleId =>
      integer().nullable().references(RecurrenceRules, #id)();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get completedAt => dateTime().nullable()();
}
