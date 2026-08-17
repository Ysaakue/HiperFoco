import 'package:drift/drift.dart';

import '../../../features/tasks/domain/entities/recurrence_frequency.dart';

/// A simplified RRULE, shared by recurring tasks and standalone recurring
/// reminders. Recurrence is virtual — [RecurrenceEngine] computes occurrence
/// dates on demand from this rule; no per-occurrence row is ever stored here.
@DataClassName('RecurrenceRuleRow')
class RecurrenceRules extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get frequency => textEnum<RecurrenceFrequency>()();

  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// Comma-separated ISO weekdays (1=Monday..7=Sunday). Only meaningful for
  /// [RecurrenceFrequency.weekly]; null falls back to [startDate]'s weekday.
  TextColumn get byWeekdays => text().nullable()();

  /// Day of month, clamped to the target month's actual length when it
  /// overflows (e.g. 31 in a 30-day month). Only meaningful for
  /// [RecurrenceFrequency.monthly]; null falls back to [startDate]'s day.
  IntColumn get byMonthDay => integer().nullable()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();
}
