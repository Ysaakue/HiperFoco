import 'package:equatable/equatable.dart';

import 'category_duration.dart';
import 'daily_duration.dart';

/// The aggregated data a statistics period view renders: how tracked time
/// splits across categories, and how it trends day by day.
class StatisticsSummary extends Equatable {
  const StatisticsSummary({
    required this.categoryTotals,
    required this.dailyTotals,
  });

  final List<CategoryDuration> categoryTotals;
  final List<DailyDuration> dailyTotals;

  int get totalDurationSeconds =>
      categoryTotals.fold(0, (sum, c) => sum + c.totalDurationSeconds);

  @override
  List<Object?> get props => [categoryTotals, dailyTotals];
}
