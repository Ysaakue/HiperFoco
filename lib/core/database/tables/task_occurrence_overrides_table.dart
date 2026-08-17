import 'package:drift/drift.dart';

import '../../../features/tasks/domain/entities/occurrence_status.dart';
import 'tasks_table.dart';

/// An exception to a single virtual occurrence of a recurring task — marking
/// it done, skipped, or moved to a different date — without materializing a
/// row for every occurrence a recurrence rule could ever produce.
@DataClassName('TaskOccurrenceOverrideRow')
class TaskOccurrenceOverrides extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().references(Tasks, #id)();

  /// The occurrence's original date, as computed by [RecurrenceEngine] —
  /// never the rescheduled date, so the original slot always matches back
  /// to this override.
  DateTimeColumn get occurrenceDate => dateTime()();

  TextColumn get status => textEnum<OccurrenceStatus>()();

  /// Only set when [status] is [OccurrenceStatus.rescheduled].
  DateTimeColumn get rescheduledTo => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {taskId, occurrenceDate},
      ];
}
