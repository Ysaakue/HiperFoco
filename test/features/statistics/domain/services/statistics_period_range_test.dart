import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/statistics/domain/entities/statistics_period.dart';
import 'package:hiperfoco/features/statistics/domain/services/statistics_period_range.dart';

void main() {
  const range = StatisticsPeriodRange();

  group('rangeFor', () {
    test('day: covers just that calendar day', () {
      final result = range.rangeFor(StatisticsPeriod.day, DateTime(2026, 3, 10, 14, 30));

      expect(result.start, DateTime(2026, 3, 10));
      expect(result.end, DateTime(2026, 3, 11));
    });

    test('week: Monday through the following Monday, regardless of which '
        'weekday the reference date falls on', () {
      // 2026-03-10 is a Tuesday.
      final fromTuesday = range.rangeFor(StatisticsPeriod.week, DateTime(2026, 3, 10));
      // 2026-03-15 is a Sunday, still the same calendar week.
      final fromSunday = range.rangeFor(StatisticsPeriod.week, DateTime(2026, 3, 15));

      expect(fromTuesday.start, DateTime(2026, 3, 9)); // Monday
      expect(fromTuesday.end, DateTime(2026, 3, 16));
      expect(fromSunday, fromTuesday);
    });

    test('month: the 1st through the 1st of the next month', () {
      final result = range.rangeFor(StatisticsPeriod.month, DateTime(2026, 2, 20));

      expect(result.start, DateTime(2026, 2, 1));
      expect(result.end, DateTime(2026, 3, 1));
    });

    test('month: December rolls over into January of the next year', () {
      final result = range.rangeFor(StatisticsPeriod.month, DateTime(2026, 12, 5));

      expect(result.start, DateTime(2026, 12, 1));
      expect(result.end, DateTime(2027, 1, 1));
    });
  });

  group('shift', () {
    test('day: moves by whole days', () {
      final next = range.shift(StatisticsPeriod.day, DateTime(2026, 3, 10), 1);
      final prev = range.shift(StatisticsPeriod.day, DateTime(2026, 3, 10), -1);

      expect(next, DateTime(2026, 3, 11));
      expect(prev, DateTime(2026, 3, 9));
    });

    test('week: moves by 7 days', () {
      final next = range.shift(StatisticsPeriod.week, DateTime(2026, 3, 10), 1);

      expect(next, DateTime(2026, 3, 17));
    });

    test('month: lands on the 1st of the target month, clamping day-of-month '
        'issues away entirely', () {
      final next = range.shift(StatisticsPeriod.month, DateTime(2026, 1, 31), 1);

      expect(next, DateTime(2026, 2, 1));
    });
  });

  group('containsToday', () {
    test('true when today falls inside the period', () {
      final result = range.containsToday(
        StatisticsPeriod.week,
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 12, 18),
      );

      expect(result, isTrue);
    });

    test('false when today falls outside the period', () {
      final result = range.containsToday(
        StatisticsPeriod.week,
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 20),
      );

      expect(result, isFalse);
    });

    test('false for a past month even if today is later in the same month '
        'number a year apart', () {
      final result = range.containsToday(
        StatisticsPeriod.month,
        DateTime(2025, 3, 1),
        DateTime(2026, 3, 15),
      );

      expect(result, isFalse);
    });
  });
}
