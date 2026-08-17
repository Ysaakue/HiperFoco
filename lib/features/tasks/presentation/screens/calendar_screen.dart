import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../timer/presentation/providers/timer_providers.dart';
import '../../domain/entities/occurrence_status.dart';
import '../../domain/entities/task_occurrence.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedMonth = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthStart = _focusedMonth;
    final gridStart =
        monthStart.subtract(Duration(days: monthStart.weekday - 1));
    final gridEnd = gridStart.add(const Duration(days: 42));

    final occurrencesAsync =
        ref.watch(occurrencesForRangeProvider(gridStart, gridEnd));
    final categoriesAsync =
        ref.watch(categoriesListProvider(includeArchived: true));
    final categoriesById = {
      for (final category in categoriesAsync.valueOrNull ?? <Category>[])
        category.id: category,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCalendar)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(
                      Localizations.localeOf(context).toString(),
                    ).format(_focusedMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: occurrencesAsync.when(
                data: (occurrences) {
                  final byDay = <DateTime, List<TaskOccurrence>>{};
                  for (final occurrence in occurrences) {
                    byDay.putIfAbsent(occurrence.date, () => []).add(occurrence);
                  }
                  return _MonthGrid(
                    gridStart: gridStart,
                    month: _focusedMonth,
                    selectedDay: _selectedDay,
                    occurrencesByDay: byDay,
                    categoriesById: categoriesById,
                    onSelectDay: (day) => setState(() => _selectedDay = day),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('$error'),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _DayDetail(
              day: _selectedDay,
              occurrences: (occurrencesAsync.valueOrNull ?? const [])
                  .where((occurrence) => occurrence.date == _selectedDay)
                  .toList(),
              categoriesById: categoriesById,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.gridStart,
    required this.month,
    required this.selectedDay,
    required this.occurrencesByDay,
    required this.categoriesById,
    required this.onSelectDay,
  });

  final DateTime gridStart;
  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<TaskOccurrence>> occurrencesByDay;
  final Map<int, Category> categoriesById;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final weekdayLabels = [
      l10n.recurrenceWeekdayMon,
      l10n.recurrenceWeekdayTue,
      l10n.recurrenceWeekdayWed,
      l10n.recurrenceWeekdayThu,
      l10n.recurrenceWeekdayFri,
      l10n.recurrenceWeekdaySat,
      l10n.recurrenceWeekdaySun,
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < 42; i++) _buildCell(context, i, todayDate),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, int index, DateTime today) {
    final day = gridStart.add(Duration(days: index));
    final isCurrentMonth = day.month == month.month;
    final isSelected = day == selectedDay;
    final isToday = day == today;
    final dayOccurrences = occurrencesByDay[day] ?? const [];
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onSelectDay(day),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          border: isToday && !isSelected
              ? Border.all(color: colorScheme.primary)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isCurrentMonth
                    ? (isSelected ? colorScheme.onPrimaryContainer : null)
                    : colorScheme.outline,
              ),
            ),
            if (dayOccurrences.isNotEmpty)
              Wrap(
                spacing: 2,
                children: [
                  for (final occurrence
                      in dayOccurrences.take(4))
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoriesById[occurrence.task.categoryId] != null
                            ? Color(
                                categoriesById[occurrence.task.categoryId]!
                                    .colorValue,
                              )
                            : Colors.grey,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDetail extends ConsumerWidget {
  const _DayDetail({
    required this.day,
    required this.occurrences,
    required this.categoriesById,
  });

  final DateTime day;
  final List<TaskOccurrence> occurrences;
  final Map<int, Category> categoriesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TrackedTimeRow(day: day),
        const SizedBox(height: 12),
        if (occurrences.isEmpty)
          EmptyState(
            icon: Icons.event_available_outlined,
            message: l10n.calendarNoTasksForDay,
          )
        else
          for (final occurrence in occurrences)
            _OccurrenceTile(
              occurrence: occurrence,
              category: categoriesById[occurrence.task.categoryId],
            ),
      ],
    );
  }
}

class _TrackedTimeRow extends ConsumerWidget {
  const _TrackedTimeRow({required this.day});

  final DateTime day;

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final seconds = _isToday
        ? ref.watch(todayTotalDurationSecondsProvider).valueOrNull ?? 0
        : (ref.watch(archivedDayProvider(day)).valueOrNull ?? const [])
            .fold<int>(0, (sum, entry) => sum + entry.totalDurationSeconds);

    return Row(
      children: [
        Text(
          l10n.calendarTrackedTime,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Spacer(),
        Text(
          DurationFormatter.hms(Duration(seconds: seconds)),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _OccurrenceTile extends ConsumerWidget {
  const _OccurrenceTile({required this.occurrence, required this.category});

  final TaskOccurrence occurrence;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final task = occurrence.task;
    final color = category != null ? Color(category!.colorValue) : Colors.grey;
    final isResolved = occurrence.isDone || occurrence.isSkipped;

    return ListTile(
      leading: Checkbox(
        value: occurrence.isDone,
        onChanged: (value) => _toggleDone(ref, value ?? false),
      ),
      title: Text(
        task.title,
        style: isResolved
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(category?.name ?? ''),
          if (task.isRecurring) ...[
            const SizedBox(width: 6),
            const Icon(Icons.repeat, size: 14),
          ],
          if (occurrence.isSkipped) ...[
            const SizedBox(width: 6),
            Text(l10n.calendarSkipped, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
      trailing: task.isRecurring
          ? PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(ref, value),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'skip', child: Text(l10n.calendarSkip)),
                PopupMenuItem(value: 'reset', child: Text(l10n.calendarReset)),
              ],
            )
          : null,
    );
  }

  void _toggleDone(WidgetRef ref, bool value) {
    final task = occurrence.task;
    if (task.isRecurring) {
      if (value) {
        ref.read(setOccurrenceStatusUseCaseProvider).call(
              task.id,
              occurrence.date,
              OccurrenceStatus.done,
            );
      } else {
        ref
            .read(clearOccurrenceOverrideUseCaseProvider)
            .call(task.id, occurrence.date);
      }
    } else {
      ref.read(setTaskStatusUseCaseProvider).call(
            task.id,
            value ? TaskStatus.completed : TaskStatus.pending,
          );
    }
  }

  void _handleMenuAction(WidgetRef ref, String action) {
    final task = occurrence.task;
    switch (action) {
      case 'skip':
        ref.read(setOccurrenceStatusUseCaseProvider).call(
              task.id,
              occurrence.date,
              OccurrenceStatus.skipped,
            );
      case 'reset':
        ref
            .read(clearOccurrenceOverrideUseCaseProvider)
            .call(task.id, occurrence.date);
    }
  }
}
