import 'package:drift/drift.dart';

import 'goals_table.dart';

@DataClassName('GoalStepRow')
class GoalSteps extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get goalId => integer().references(Goals, #id)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Set when this step has been promoted to a schedulable task. Not a hard
  /// FK: tasks can be hard-deleted (same reasoning as
  /// `TimerHistoryDaily.taskId`), and `DeleteTask` clears this back to null
  /// when the linked task goes away so the step correctly shows as
  /// "not promoted" again instead of pointing at nothing.
  IntColumn get linkedTaskId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
