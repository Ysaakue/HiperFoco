import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../timer/domain/entities/timer_interval.dart';
import '../../../timer/presentation/providers/timer_providers.dart';
import '../../domain/entities/statistics_period.dart';
import '../../domain/entities/statistics_summary.dart';
import '../../domain/services/statistics_aggregator.dart';
import '../../domain/services/statistics_period_range.dart';

part 'statistics_providers.g.dart';

/// Combines the compacted history (`archivedBetweenProvider`) with today's
/// still-hot intervals (`intervalsForDayProvider`), re-running whenever
/// either source changes — mirrors the same "combine multiple stream
/// providers via async*" pattern already used by `occurrencesForRange` for
/// the calendar.
@riverpod
Stream<StatisticsSummary> statisticsSummary(
  Ref ref,
  StatisticsPeriod period,
  DateTime referenceDate,
) async* {
  const periodRange = StatisticsPeriodRange();
  final range = periodRange.rangeFor(period, referenceDate);

  final archived = await ref.watch(
    archivedBetweenProvider(range.start, range.end).future,
  );

  final today = clock.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  final includesToday =
      periodRange.containsToday(period, referenceDate, today);
  final todayIntervals = includesToday
      ? await ref.watch(intervalsForDayProvider(todayDay).future)
      : const <TimerInterval>[];

  yield const StatisticsAggregator().aggregate(
    start: range.start,
    end: range.end,
    archived: archived,
    todayIntervals: todayIntervals,
    today: todayDay,
  );
}
