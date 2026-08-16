import 'package:drift/drift.dart';

import 'timer_sessions_table.dart';

@DataClassName('TimerIntervalRow')
class TimerIntervals extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(TimerSessions, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime().nullable()();
}
