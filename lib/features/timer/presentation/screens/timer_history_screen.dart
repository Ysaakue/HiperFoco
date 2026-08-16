import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
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
    final intervalsAsync = ref.watch(intervalsForDayProvider(_day));
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: true));

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
      body: intervalsAsync.when(
        data: (intervals) {
          if (intervals.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              message: l10n.timerHistoryEmpty,
            );
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
              final color = category != null
                  ? Color(category.colorValue)
                  : Theme.of(context).colorScheme.outline;
              final icon = category != null
                  ? CategoryIcons.resolve(category.iconKey)
                  : Icons.category_outlined;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  child: Icon(icon),
                ),
                title: Text(category?.name ?? l10n.timerHistoryUnknownCategory),
                subtitle: Text(
                  '${DateTimeFormatter.hm(interval.startedAt)} – '
                  '${interval.endedAt != null ? DateTimeFormatter.hm(interval.endedAt!) : l10n.timerRunning}',
                ),
                trailing: Text(
                  DurationFormatter.hms(interval.elapsedAt(now)),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
    );
  }
}
