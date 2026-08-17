import '../../../timer/domain/entities/timer_history_entry.dart';
import '../../../timer/domain/entities/timer_interval.dart';
import '../entities/category_duration.dart';
import '../entities/daily_duration.dart';
import '../entities/statistics_summary.dart';

/// Pure aggregation from raw timer data into a [StatisticsSummary] — no I/O,
/// fully unit-testable. Combines the compacted history (every day already
/// archived by `DailyArchiveService`) with today's still-hot intervals, when
/// today falls inside the requested range.
class StatisticsAggregator {
  const StatisticsAggregator();

  StatisticsSummary aggregate({
    required DateTime start,
    required DateTime end,
    required List<TimerHistoryEntry> archived,
    required List<TimerInterval> todayIntervals,
    required DateTime today,
  }) {
    final categoryTotals = <int, int>{};
    final dailyTotals = <DateTime, int>{};

    // Seed every day in range with 0 so a trend chart has a continuous axis
    // even for days with no tracked time.
    for (var day = start; day.isBefore(end); day = day.add(const Duration(days: 1))) {
      dailyTotals[day] = 0;
    }

    // Every entry's date is guaranteed to already be a key in dailyTotals —
    // it was seeded above from the same [start, end) range these entries
    // were queried against — so plain indexing is enough; there's no
    // "absent" case to handle.
    for (final entry in archived) {
      categoryTotals.update(
        entry.categoryId,
        (v) => v + entry.totalDurationSeconds,
        ifAbsent: () => entry.totalDurationSeconds,
      );
      dailyTotals[entry.date] = dailyTotals[entry.date]! + entry.totalDurationSeconds;
    }

    if (!today.isBefore(start) && today.isBefore(end)) {
      for (final interval in todayIntervals) {
        final endedAt = interval.endedAt;
        if (endedAt == null) continue;
        final seconds = endedAt.difference(interval.startedAt).inSeconds;
        categoryTotals.update(
          interval.categoryId,
          (v) => v + seconds,
          ifAbsent: () => seconds,
        );
        dailyTotals[today] = dailyTotals[today]! + seconds;
      }
    }

    final sortedCategoryTotals = [
      for (final e in categoryTotals.entries)
        CategoryDuration(categoryId: e.key, totalDurationSeconds: e.value),
    ]..sort((a, b) => b.totalDurationSeconds.compareTo(a.totalDurationSeconds));

    final sortedDailyTotals = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return StatisticsSummary(
      categoryTotals: sortedCategoryTotals,
      dailyTotals: [
        for (final e in sortedDailyTotals)
          DailyDuration(date: e.key, totalDurationSeconds: e.value),
      ],
    );
  }
}
