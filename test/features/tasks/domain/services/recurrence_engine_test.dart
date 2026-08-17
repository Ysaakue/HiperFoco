import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:hiperfoco/features/tasks/domain/services/recurrence_engine.dart';

void main() {
  const engine = RecurrenceEngine();

  RecurrenceRule dailyRule({
    required DateTime startDate,
    int interval = 1,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      id: 1,
      frequency: RecurrenceFrequency.daily,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
    );
  }

  RecurrenceRule weeklyRule({
    required DateTime startDate,
    int interval = 1,
    List<int>? byWeekdays,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      id: 2,
      frequency: RecurrenceFrequency.weekly,
      interval: interval,
      byWeekdays: byWeekdays,
      startDate: startDate,
      endDate: endDate,
    );
  }

  RecurrenceRule monthlyRule({
    required DateTime startDate,
    int interval = 1,
    int? byMonthDay,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      id: 3,
      frequency: RecurrenceFrequency.monthly,
      interval: interval,
      byMonthDay: byMonthDay,
      startDate: startDate,
      endDate: endDate,
    );
  }

  group('daily', () {
    test('every day within the range', () {
      final rule = dailyRule(startDate: DateTime(2026, 3, 1));

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 5),
      );

      expect(occurrences, [
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 3),
        DateTime(2026, 3, 4),
      ]);
    });

    test('every 3rd day stays anchored to startDate regardless of query range', () {
      final rule = dailyRule(startDate: DateTime(2026, 3, 1), interval: 3);

      // Query a range that doesn't start on an occurrence day.
      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 8),
        DateTime(2026, 3, 15),
      );

      // Occurrences from startDate are 3/1, 3/4, 3/7, 3/10, 3/13, 3/16...
      expect(occurrences, [DateTime(2026, 3, 10), DateTime(2026, 3, 13)]);
    });

    test('nothing before startDate even if the query range starts earlier', () {
      final rule = dailyRule(startDate: DateTime(2026, 3, 10));

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 12),
      );

      expect(occurrences, [DateTime(2026, 3, 10), DateTime(2026, 3, 11)]);
    });

    test('respects endDate as inclusive', () {
      final rule = dailyRule(
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 3),
      );

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 10),
      );

      expect(occurrences, [
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 3),
      ]);
    });

    test('empty when the query range is entirely after endDate', () {
      final rule = dailyRule(
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 3),
      );

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 4, 1),
        DateTime(2026, 4, 10),
      );

      expect(occurrences, isEmpty);
    });
  });

  group('weekly', () {
    test('defaults to startDate\'s weekday when byWeekdays is not set', () {
      // 2026-03-02 is a Monday.
      final rule = weeklyRule(startDate: DateTime(2026, 3, 2));

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 23),
      );

      expect(occurrences, [
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 9),
        DateTime(2026, 3, 16),
      ]);
    });

    test('multiple weekdays per week, sorted', () {
      // 2026-03-02 is a Monday; ask for Mon/Wed/Fri (1, 3, 5).
      final rule = weeklyRule(
        startDate: DateTime(2026, 3, 2),
        byWeekdays: [5, 1, 3],
      );

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 9),
      );

      expect(occurrences, [
        DateTime(2026, 3, 2), // Mon
        DateTime(2026, 3, 4), // Wed
        DateTime(2026, 3, 6), // Fri
      ]);
    });

    test('every 2nd week stays anchored to startDate\'s week', () {
      // Week of 3/2 (anchor), skip week of 3/9, occurs again week of 3/16.
      final rule = weeklyRule(
        startDate: DateTime(2026, 3, 2),
        interval: 2,
        byWeekdays: [1],
      );

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 30),
      );

      expect(occurrences, [DateTime(2026, 3, 2), DateTime(2026, 3, 16)]);
    });

    test('a weekday before startDate within the anchor week is excluded', () {
      // startDate is Wednesday 3/4; asking for Mon/Wed that same week must
      // not include Monday 3/2, which is before the rule even starts.
      final rule = weeklyRule(
        startDate: DateTime(2026, 3, 4),
        byWeekdays: [1, 3],
      );

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 8),
      );

      expect(occurrences, [DateTime(2026, 3, 4)]);
    });
  });

  group('monthly', () {
    test('same day every month', () {
      final rule = monthlyRule(startDate: DateTime(2026, 1, 15));

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 1, 1),
        DateTime(2026, 4, 1),
      );

      expect(occurrences, [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 15),
        DateTime(2026, 3, 15),
      ]);
    });

    test('clamps day 31 to the actual last day of a shorter month', () {
      final rule = monthlyRule(startDate: DateTime(2026, 1, 31), byMonthDay: 31);

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 1, 1),
        DateTime(2026, 5, 1),
      );

      // Jan (31), Feb (28, 2026 is not a leap year), Mar (31), Apr (30).
      expect(occurrences, [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      ]);
    });

    test('clamps day 31 in February of a leap year to the 29th', () {
      final rule = monthlyRule(startDate: DateTime(2028, 1, 31), byMonthDay: 31);

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2028, 2, 1),
        DateTime(2028, 3, 1),
      );

      expect(occurrences, [DateTime(2028, 2, 29)]);
    });

    test('every 3rd month stays anchored to startDate\'s month', () {
      final rule = monthlyRule(startDate: DateTime(2026, 1, 10), interval: 3);

      final occurrences = engine.occurrencesBetween(
        rule,
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      );

      expect(occurrences, [
        DateTime(2026, 1, 10),
        DateTime(2026, 4, 10),
        DateTime(2026, 7, 10),
        DateTime(2026, 10, 10),
      ]);
    });
  });

  test('interval of 0 or negative is treated as 1 instead of looping forever', () {
    final rule = dailyRule(startDate: DateTime(2026, 3, 1), interval: 0);

    final occurrences = engine.occurrencesBetween(
      rule,
      DateTime(2026, 3, 1),
      DateTime(2026, 3, 4),
    );

    expect(occurrences, [
      DateTime(2026, 3, 1),
      DateTime(2026, 3, 2),
      DateTime(2026, 3, 3),
    ]);
  });
}
