import '../entities/recurrence_frequency.dart';
import '../entities/recurrence_rule.dart';

/// Computes virtual occurrence dates for a [RecurrenceRule] on demand — no
/// occurrence is ever persisted; only exceptions to it are (see
/// `TaskOccurrenceOverride`). Pure and deterministic: same inputs, same
/// output, no clock/IO involved.
class RecurrenceEngine {
  const RecurrenceEngine();

  /// Occurrence dates (date-only, normalized to midnight) within
  /// `[rangeStart, rangeEnd)`, additionally bounded by the rule's own
  /// [RecurrenceRule.startDate] and [RecurrenceRule.endDate] (inclusive).
  List<DateTime> occurrencesBetween(
    RecurrenceRule rule,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final start = _dateOnly(rule.startDate);
    final queryStart = _dateOnly(rangeStart);
    final effectiveStart = start.isAfter(queryStart) ? start : queryStart;

    var effectiveEnd = _dateOnly(rangeEnd);
    final ruleEnd = rule.endDate;
    if (ruleEnd != null) {
      final ruleEndExclusive = _dateOnly(ruleEnd).add(const Duration(days: 1));
      if (ruleEndExclusive.isBefore(effectiveEnd)) {
        effectiveEnd = ruleEndExclusive;
      }
    }
    if (!effectiveStart.isBefore(effectiveEnd)) return const [];

    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        return _dailyOccurrences(rule, start, effectiveStart, effectiveEnd);
      case RecurrenceFrequency.weekly:
        return _weeklyOccurrences(rule, start, effectiveStart, effectiveEnd);
      case RecurrenceFrequency.monthly:
        return _monthlyOccurrences(rule, start, effectiveStart, effectiveEnd);
    }
  }

  List<DateTime> _dailyOccurrences(
    RecurrenceRule rule,
    DateTime start,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final interval = _clampInterval(rule.interval);
    final daysSinceStart = rangeStart.difference(start).inDays;
    final steps = daysSinceStart <= 0 ? 0 : (daysSinceStart / interval).ceil();

    final occurrences = <DateTime>[];
    var date = start.add(Duration(days: steps * interval));
    while (date.isBefore(rangeEnd)) {
      if (!date.isBefore(rangeStart)) occurrences.add(date);
      date = date.add(Duration(days: interval));
    }
    return occurrences;
  }

  List<DateTime> _weeklyOccurrences(
    RecurrenceRule rule,
    DateTime start,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final interval = _clampInterval(rule.interval);
    final weekdays = (rule.byWeekdays ?? [start.weekday]).toList()..sort();
    final weekAnchor = start.subtract(Duration(days: start.weekday - 1));
    final rangeStartWeek =
        rangeStart.subtract(Duration(days: rangeStart.weekday - 1));

    final weeksSinceAnchor = rangeStartWeek.difference(weekAnchor).inDays ~/ 7;
    var weekOffset = weeksSinceAnchor - (weeksSinceAnchor % interval);
    if (weekOffset < 0) weekOffset = 0;

    final occurrences = <DateTime>[];
    var week = weekAnchor.add(Duration(days: weekOffset * 7));
    while (week.isBefore(rangeEnd)) {
      for (final weekday in weekdays) {
        final candidate = week.add(Duration(days: weekday - 1));
        if (!candidate.isBefore(start) &&
            !candidate.isBefore(rangeStart) &&
            candidate.isBefore(rangeEnd)) {
          occurrences.add(candidate);
        }
      }
      week = week.add(Duration(days: interval * 7));
    }
    occurrences.sort();
    return occurrences;
  }

  List<DateTime> _monthlyOccurrences(
    RecurrenceRule rule,
    DateTime start,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final interval = _clampInterval(rule.interval);
    final targetDay = rule.byMonthDay ?? start.day;

    var monthIndex = start.year * 12 + (start.month - 1);
    final rangeStartMonthIndex = rangeStart.year * 12 + (rangeStart.month - 1);
    final monthsSinceStart = rangeStartMonthIndex - monthIndex;
    if (monthsSinceStart > 0) {
      monthIndex += (monthsSinceStart / interval).ceil() * interval;
    }

    final occurrences = <DateTime>[];
    while (true) {
      final year = monthIndex ~/ 12;
      final month = monthIndex % 12 + 1;
      // Clamp the target day to the target month's actual length instead of
      // letting DateTime's constructor silently roll it into the next
      // month (e.g. day 31 in a 30-day month becoming the 1st).
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final day = targetDay > daysInMonth ? daysInMonth : targetDay;
      final candidate = DateTime(year, month, day);

      if (!candidate.isBefore(rangeEnd)) break;
      if (!candidate.isBefore(start) && !candidate.isBefore(rangeStart)) {
        occurrences.add(candidate);
      }
      monthIndex += interval;
    }
    return occurrences;
  }

  int _clampInterval(int interval) => interval < 1 ? 1 : interval;

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
