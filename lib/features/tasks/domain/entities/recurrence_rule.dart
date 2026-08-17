import 'package:equatable/equatable.dart';

import 'recurrence_frequency.dart';

class RecurrenceRule extends Equatable {
  const RecurrenceRule({
    required this.id,
    required this.frequency,
    required this.interval,
    this.byWeekdays,
    this.byMonthDay,
    required this.startDate,
    this.endDate,
  });

  final int id;
  final RecurrenceFrequency frequency;

  /// Every [interval]-th day/week/month, depending on [frequency].
  final int interval;

  /// ISO weekdays (1=Monday..7=Sunday). Only meaningful for
  /// [RecurrenceFrequency.weekly]; null falls back to [startDate]'s weekday.
  final List<int>? byWeekdays;

  /// Only meaningful for [RecurrenceFrequency.monthly]; null falls back to
  /// [startDate]'s day.
  final int? byMonthDay;

  final DateTime startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props =>
      [id, frequency, interval, byWeekdays, byMonthDay, startDate, endDate];
}
