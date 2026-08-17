import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/category_duration.dart';
import '../../domain/entities/daily_duration.dart';
import '../../domain/entities/statistics_period.dart';
import '../../domain/entities/statistics_summary.dart';
import '../../domain/services/statistics_period_range.dart';
import '../providers/statistics_providers.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  static const _periodRange = StatisticsPeriodRange();

  StatisticsPeriod _period = StatisticsPeriod.week;
  late DateTime _referenceDate;

  @override
  void initState() {
    super.initState();
    _referenceDate = _today();
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isCurrentPeriod =>
      _periodRange.containsToday(_period, _referenceDate, DateTime.now());

  void _changePeriodType(StatisticsPeriod period) {
    setState(() {
      _period = period;
      // Re-anchor to today whenever the period type changes, so switching
      // to Week/Month always starts on the current one rather than
      // reinterpreting whatever day was in view under the old period type.
      _referenceDate = _today();
    });
  }

  void _shift(int delta) {
    setState(() {
      _referenceDate = _periodRange.shift(_period, _referenceDate, delta);
    });
  }

  String _periodLabel(AppLocalizations l10n, Locale locale) {
    final range = _periodRange.rangeFor(_period, _referenceDate);
    switch (_period) {
      case StatisticsPeriod.day:
        return _isCurrentPeriod
            ? l10n.timerHistoryToday
            : DateTimeFormatter.dmy(range.start);
      case StatisticsPeriod.week:
        final lastDay = range.end.subtract(const Duration(days: 1));
        return '${DateTimeFormatter.dmy(range.start)} '
            '– ${DateTimeFormatter.dmy(lastDay)}';
      case StatisticsPeriod.month:
        return DateFormat.yMMMM(locale.toString()).format(range.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final summaryAsync =
        ref.watch(statisticsSummaryProvider(_period, _referenceDate));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStats)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<StatisticsPeriod>(
              segments: [
                ButtonSegment(
                  value: StatisticsPeriod.day,
                  label: Text(l10n.statisticsPeriodDay),
                ),
                ButtonSegment(
                  value: StatisticsPeriod.week,
                  label: Text(l10n.statisticsPeriodWeek),
                ),
                ButtonSegment(
                  value: StatisticsPeriod.month,
                  label: Text(l10n.statisticsPeriodMonth),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (selection) =>
                  _changePeriodType(selection.first),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              Text(_periodLabel(l10n, locale)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _isCurrentPeriod ? null : () => _shift(1),
              ),
            ],
          ),
          Expanded(
            child: summaryAsync.when(
              data: (summary) {
                if (summary.totalDurationSeconds == 0) {
                  return EmptyState(
                    icon: Icons.bar_chart_outlined,
                    message: l10n.statisticsNoData,
                  );
                }
                return _StatisticsBody(summary: summary, period: _period);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('$error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsBody extends ConsumerWidget {
  const _StatisticsBody({required this.summary, required this.period});

  final StatisticsSummary summary;
  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: true));
    final categoriesById = {
      for (final category in categoriesAsync.valueOrNull ?? <Category>[])
        category.id: category,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${l10n.statisticsTotal}: '
          '${DurationFormatter.hms(Duration(seconds: summary.totalDurationSeconds))}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.statisticsByCategory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _CategoryPieChart(summary: summary, categoriesById: categoriesById),
        const SizedBox(height: 8),
        for (final entry in summary.categoryTotals)
          _CategoryLegendTile(
            category: categoriesById[entry.categoryId],
            entry: entry,
            totalDurationSeconds: summary.totalDurationSeconds,
            unknownLabel: l10n.timerHistoryUnknownCategory,
          ),
        if (summary.dailyTotals.length > 1) ...[
          const SizedBox(height: 16),
          Text(
            l10n.statisticsTrend,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: _TrendBarChart(dailyTotals: summary.dailyTotals, period: period),
          ),
        ],
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.summary, required this.categoriesById});

  final StatisticsSummary summary;
  final Map<int, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 36,
          sections: [
            for (final entry in summary.categoryTotals)
              PieChartSectionData(
                value: entry.totalDurationSeconds.toDouble(),
                color: categoriesById[entry.categoryId] != null
                    ? Color(categoriesById[entry.categoryId]!.colorValue)
                    : outline,
                showTitle: false,
                radius: 50,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLegendTile extends StatelessWidget {
  const _CategoryLegendTile({
    required this.category,
    required this.entry,
    required this.totalDurationSeconds,
    required this.unknownLabel,
  });

  final Category? category;
  final CategoryDuration entry;
  final int totalDurationSeconds;
  final String unknownLabel;

  @override
  Widget build(BuildContext context) {
    final color = category != null
        ? Color(category!.colorValue)
        : Theme.of(context).colorScheme.outline;
    final icon = category != null
        ? CategoryIcons.resolve(category!.iconKey)
        : Icons.category_outlined;
    final percentage = totalDurationSeconds == 0
        ? 0
        : (entry.totalDurationSeconds / totalDurationSeconds * 100).round();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        child: Icon(icon, size: 20),
      ),
      title: Text(category?.name ?? unknownLabel),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(DurationFormatter.hms(Duration(seconds: entry.totalDurationSeconds))),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  const _TrendBarChart({required this.dailyTotals, required this.period});

  final List<DailyDuration> dailyTotals;
  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final maxMinutes = dailyTotals.fold<int>(
          0,
          (m, d) => d.totalDurationSeconds > m ? d.totalDurationSeconds : m,
        ) /
        60;

    return BarChart(
      BarChartData(
        maxY: maxMinutes == 0 ? 1 : maxMinutes * 1.2,
        barGroups: [
          for (var i = 0; i < dailyTotals.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dailyTotals[i].totalDurationSeconds / 60,
                  color: color,
                  width: period == StatisticsPeriod.month ? 4 : 14,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailyTotals.length) {
                  return const SizedBox.shrink();
                }
                if (period == StatisticsPeriod.month && index % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    dailyTotals[index].date.day.toString(),
                    style: TextStyle(fontSize: 10, color: labelColor),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }
}
