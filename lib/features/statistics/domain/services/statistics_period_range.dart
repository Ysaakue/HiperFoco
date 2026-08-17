import '../entities/statistics_period.dart';

/// Pure calendar math for statistics periods — no I/O, fully unit-testable.
/// Weeks start on Monday.
class StatisticsPeriodRange {
  const StatisticsPeriodRange();

  /// The half-open `[start, end)` range covering [period], anchored on
  /// whichever day/week/month [referenceDate] falls in.
  ({DateTime start, DateTime end}) rangeFor(
    StatisticsPeriod period,
    DateTime referenceDate,
  ) {
    final day =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    switch (period) {
      case StatisticsPeriod.day:
        return (start: day, end: day.add(const Duration(days: 1)));
      case StatisticsPeriod.week:
        final start = day.subtract(Duration(days: day.weekday - 1));
        return (start: start, end: start.add(const Duration(days: 7)));
      case StatisticsPeriod.month:
        final start = DateTime(day.year, day.month);
        final end = DateTime(day.year, day.month + 1);
        return (start: start, end: end);
    }
  }

  /// Moves [referenceDate] to the equivalent day in the next/previous period
  /// (`delta` of -1/+1) — used by prev/next navigation. For month, always
  /// lands on the 1st of the target month, since only "which month" matters.
  DateTime shift(StatisticsPeriod period, DateTime referenceDate, int delta) {
    final day =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    switch (period) {
      case StatisticsPeriod.day:
        return day.add(Duration(days: delta));
      case StatisticsPeriod.week:
        return day.add(Duration(days: 7 * delta));
      case StatisticsPeriod.month:
        return DateTime(day.year, day.month + delta);
    }
  }

  /// Whether [today] falls inside the [period] anchored on [referenceDate]
  /// — used to disable "next" navigation and to decide whether the still-hot
  /// (unarchived) data for today needs to be merged in.
  bool containsToday(
    StatisticsPeriod period,
    DateTime referenceDate,
    DateTime today,
  ) {
    final range = rangeFor(period, referenceDate);
    final todayDay = DateTime(today.year, today.month, today.day);
    return !todayDay.isBefore(range.start) && todayDay.isBefore(range.end);
  }
}
