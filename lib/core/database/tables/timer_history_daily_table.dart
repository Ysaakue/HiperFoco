import 'package:drift/drift.dart';

import 'categories_table.dart';

/// Compacted, read-only daily totals produced by [DailyArchiveService]. Once
/// a day is archived, its [TimerIntervals] rows are deleted — this table is
/// the only remaining record of that day's focus time, at (day, category,
/// task) granularity instead of individual pause/resume intervals.
@DataClassName('TimerHistoryDailyRow')
class TimerHistoryDaily extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local calendar day, normalized to midnight.
  DateTimeColumn get date => dateTime()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  /// Not a hard FK: tasks can be hard-deleted (unlike categories), and
  /// archived history must survive that.
  IntColumn get taskId => integer().nullable()();

  IntColumn get totalDurationSeconds => integer()();

  IntColumn get sessionCount => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, categoryId, taskId},
      ];
}
