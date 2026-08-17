import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../providers/timer_providers.dart';

class TimerHistoryScreen extends ConsumerStatefulWidget {
  const TimerHistoryScreen({super.key});

  @override
  ConsumerState<TimerHistoryScreen> createState() =>
      _TimerHistoryScreenState();
}

class _TimerHistoryScreenState extends ConsumerState<TimerHistoryScreen> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  bool get _isToday => DateTimeFormatter.isSameDay(_day, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  setState(() => _day = _day.subtract(const Duration(days: 1))),
            ),
            Text(_isToday ? l10n.timerHistoryToday : DateTimeFormatter.dmy(_day)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isToday
                  ? null
                  : () => setState(() => _day = _day.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
      // Today's data is still "hot" (per-interval detail in TimerIntervals);
      // every earlier day has already been compacted by DailyArchiveService
      // into per-category totals, so it needs a different read and a
      // different row layout — there is no start/end time to show anymore.
      body: _isToday ? _HotDayView(day: _day) : _ArchivedDayView(day: _day),
    );
  }
}

class _HotDayView extends ConsumerWidget {
  const _HotDayView({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final intervalsAsync = ref.watch(intervalsForDayProvider(day));
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: true));

    return intervalsAsync.when(
      data: (intervals) {
        if (intervals.isEmpty) {
          return EmptyState(icon: Icons.history, message: l10n.timerHistoryEmpty);
        }
        final categoriesById = {
          for (final category in categoriesAsync.valueOrNull ?? [])
            category.id: category,
        };
        final now = DateTime.now();
        return ListView.builder(
          itemCount: intervals.length,
          itemBuilder: (context, index) {
            final interval = intervals[intervals.length - 1 - index];
            final category = categoriesById[interval.categoryId];
            return _CategoryAvatarTile(
              category: category,
              title: category?.name ?? l10n.timerHistoryUnknownCategory,
              subtitle: '${DateTimeFormatter.hm(interval.startedAt)} – '
                  '${interval.endedAt != null ? DateTimeFormatter.hm(interval.endedAt!) : l10n.timerRunning}',
              trailing: DurationFormatter.hms(interval.elapsedAt(now)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('$error')),
    );
  }
}

class _ArchivedDayView extends ConsumerWidget {
  const _ArchivedDayView({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(archivedDayProvider(day));
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: true));

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyState(icon: Icons.history, message: l10n.timerHistoryEmpty);
        }
        final categoriesById = {
          for (final category in categoriesAsync.valueOrNull ?? [])
            category.id: category,
        };
        final sorted = [...entries]
          ..sort((a, b) => b.totalDurationSeconds.compareTo(a.totalDurationSeconds));
        return ListView.builder(
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final entry = sorted[index];
            final category = categoriesById[entry.categoryId];
            return _CategoryAvatarTile(
              category: category,
              title: category?.name ?? l10n.timerHistoryUnknownCategory,
              subtitle: l10n.timerHistorySessionCount(entry.sessionCount),
              trailing: DurationFormatter.hms(
                Duration(seconds: entry.totalDurationSeconds),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('$error')),
    );
  }
}

class _CategoryAvatarTile extends StatelessWidget {
  const _CategoryAvatarTile({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Category? category;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final color = category != null
        ? Color(category!.colorValue)
        : Theme.of(context).colorScheme.outline;
    final icon = category != null
        ? CategoryIcons.resolve(category!.iconKey)
        : Icons.category_outlined;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(trailing, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
