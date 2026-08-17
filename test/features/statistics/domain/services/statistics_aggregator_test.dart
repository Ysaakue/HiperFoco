import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/statistics/domain/services/statistics_aggregator.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_history_entry.dart';
import 'package:hiperfoco/features/timer/domain/entities/timer_interval.dart';

void main() {
  const aggregator = StatisticsAggregator();
  final start = DateTime(2026, 3, 9); // Monday
  final end = DateTime(2026, 3, 16); // following Monday, half-open
  final today = DateTime(2026, 3, 15); // Sunday, inside the range

  test('sums archived entries into category and daily totals', () {
    final archived = [
      TimerHistoryEntry(
        date: DateTime(2026, 3, 9),
        categoryId: 1,
        totalDurationSeconds: 600,
        sessionCount: 1,
      ),
      TimerHistoryEntry(
        date: DateTime(2026, 3, 10),
        categoryId: 1,
        totalDurationSeconds: 300,
        sessionCount: 1,
      ),
      TimerHistoryEntry(
        date: DateTime(2026, 3, 10),
        categoryId: 2,
        totalDurationSeconds: 900,
        sessionCount: 1,
      ),
    ];

    final summary = aggregator.aggregate(
      start: start,
      end: end,
      archived: archived,
      todayIntervals: const [],
      today: DateTime(2026, 1, 1), // outside the range: irrelevant here
    );

    expect(summary.totalDurationSeconds, 1800);
    final byCategory = {for (final c in summary.categoryTotals) c.categoryId: c.totalDurationSeconds};
    expect(byCategory, {1: 900, 2: 900});
    // Sorted by total duration, descending; ties keep insertion order from the map.
    expect(summary.categoryTotals.first.totalDurationSeconds, 900);
  });

  test('seeds every day in [start, end) with zero, even with no data at all', () {
    final summary = aggregator.aggregate(
      start: start,
      end: end,
      archived: const [],
      todayIntervals: const [],
      today: DateTime(2026, 1, 1),
    );

    expect(summary.dailyTotals, hasLength(7));
    expect(summary.dailyTotals.every((d) => d.totalDurationSeconds == 0), isTrue);
    expect(summary.dailyTotals.first.date, start);
    expect(summary.dailyTotals.last.date, DateTime(2026, 3, 15));
  });

  test('folds in today\'s closed intervals when today falls inside the range',
      () {
    final todayIntervals = [
      TimerInterval(
        id: 1,
        sessionId: 1,
        categoryId: 1,
        startedAt: today.add(const Duration(hours: 9)),
        endedAt: today.add(const Duration(hours: 9, minutes: 30)),
      ),
      TimerInterval(
        id: 2,
        sessionId: 1,
        categoryId: 3,
        startedAt: today.add(const Duration(hours: 11)),
        endedAt: today.add(const Duration(hours: 11, minutes: 10)),
      ),
    ];

    final summary = aggregator.aggregate(
      start: start,
      end: end,
      archived: const [],
      todayIntervals: todayIntervals,
      today: today,
    );

    expect(summary.totalDurationSeconds, 2400); // 30min + 10min
    final byCategory = {for (final c in summary.categoryTotals) c.categoryId: c.totalDurationSeconds};
    expect(byCategory, {1: 1800, 3: 600});
    final todayBucket =
        summary.dailyTotals.firstWhere((d) => d.date == today);
    expect(todayBucket.totalDurationSeconds, 2400);
  });

  test('ignores today\'s still-open interval (no endedAt)', () {
    final todayIntervals = [
      TimerInterval(
        id: 1,
        sessionId: 1,
        categoryId: 1,
        startedAt: today.add(const Duration(hours: 9)),
      ),
    ];

    final summary = aggregator.aggregate(
      start: start,
      end: end,
      archived: const [],
      todayIntervals: todayIntervals,
      today: today,
    );

    expect(summary.totalDurationSeconds, 0);
  });

  test('ignores todayIntervals entirely when today falls outside the range',
      () {
    final outsideToday = DateTime(2026, 4, 1);
    final todayIntervals = [
      TimerInterval(
        id: 1,
        sessionId: 1,
        categoryId: 1,
        startedAt: outsideToday.add(const Duration(hours: 9)),
        endedAt: outsideToday.add(const Duration(hours: 10)),
      ),
    ];

    final summary = aggregator.aggregate(
      start: start,
      end: end,
      archived: const [],
      todayIntervals: todayIntervals,
      today: outsideToday,
    );

    expect(summary.totalDurationSeconds, 0);
  });
}
