import 'package:drift/drift.dart';

import '../../../features/timer/domain/entities/timer_session_status.dart';
import 'categories_table.dart';
import 'tasks_table.dart';

@DataClassName('TimerSessionRow')
class TimerSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().nullable().references(Tasks, #id)();

  IntColumn get categoryId => integer().references(Categories, #id)();

  TextColumn get status => textEnum<TimerSessionStatus>()
      .withDefault(Constant(TimerSessionStatus.running.name))();

  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get completedAt => dateTime().nullable()();

  IntColumn get totalDurationSeconds => integer().withDefault(const Constant(0))();

  /// Start time of the currently open interval. Non-null only while the
  /// session is running; mirrors the open row in [TimerIntervals] as a
  /// fast-read cache so the UI never needs a join to render live elapsed
  /// time.
  DateTimeColumn get currentIntervalStartedAt => dateTime().nullable()();
}
