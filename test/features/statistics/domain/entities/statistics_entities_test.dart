import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/statistics/domain/entities/category_duration.dart';
import 'package:hiperfoco/features/statistics/domain/entities/daily_duration.dart';
import 'package:hiperfoco/features/statistics/domain/entities/statistics_summary.dart';

void main() {
  group('CategoryDuration', () {
    test('equal when fields match', () {
      const a = CategoryDuration(categoryId: 1, totalDurationSeconds: 60);
      const b = CategoryDuration(categoryId: 1, totalDurationSeconds: 60);
      const c = CategoryDuration(categoryId: 2, totalDurationSeconds: 60);

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('DailyDuration', () {
    test('equal when fields match', () {
      final a = DailyDuration(date: DateTime(2026, 1, 1), totalDurationSeconds: 60);
      final b = DailyDuration(date: DateTime(2026, 1, 1), totalDurationSeconds: 60);
      final c = DailyDuration(date: DateTime(2026, 1, 2), totalDurationSeconds: 60);

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('StatisticsSummary', () {
    test('totalDurationSeconds sums every category bucket', () {
      const summary = StatisticsSummary(
        categoryTotals: [
          CategoryDuration(categoryId: 1, totalDurationSeconds: 100),
          CategoryDuration(categoryId: 2, totalDurationSeconds: 250),
        ],
        dailyTotals: [],
      );

      expect(summary.totalDurationSeconds, 350);
    });

    test('equal when fields match', () {
      // Built through a non-const list literal so `a` and `b` are distinct
      // instances, not canonicalized to the same const — otherwise
      // `identical(a, b)` would short-circuit before ever exercising the
      // `props`-based equality this test means to check.
      final a = StatisticsSummary(
        categoryTotals: [
          for (final id in [1]) CategoryDuration(categoryId: id, totalDurationSeconds: 60),
        ],
        dailyTotals: const [],
      );
      final b = StatisticsSummary(
        categoryTotals: [
          for (final id in [1]) CategoryDuration(categoryId: id, totalDurationSeconds: 60),
        ],
        dailyTotals: const [],
      );

      expect(a, b);
    });
  });
}
