import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/recurrence_frequency.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({this.task, this.initialCategoryId, super.key});

  final Task? task;
  final int? initialCategoryId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  static const _reminderOffsetOptions = [0, 10, 30, 60, 1440];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  int? _categoryId;
  DateTime? _dueDate;

  bool _repeatEnabled = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.weekly;
  int _interval = 1;
  Set<int> _selectedWeekdays = {};
  DateTime? _repeatEndDate;

  bool _reminderEnabled = false;
  int _reminderOffsetMinutes = 0;
  Reminder? _existingReminder;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _categoryId = task?.categoryId ?? widget.initialCategoryId;
    _dueDate = task?.dueDate;

    if (task != null) {
      if (task.recurrenceRuleId != null) _loadExistingRule(task.recurrenceRuleId!);
      _loadExistingReminder(task.id);
    }
  }

  Future<void> _loadExistingRule(int ruleId) async {
    final rule = await ref.read(recurrenceRuleRepositoryProvider).getById(ruleId);
    if (!mounted || rule == null) return;
    setState(() {
      _repeatEnabled = true;
      _frequency = rule.frequency;
      _interval = rule.interval;
      _selectedWeekdays = rule.byWeekdays?.toSet() ?? {};
      _repeatEndDate = rule.endDate;
    });
  }

  Future<void> _loadExistingReminder(int taskId) async {
    final reminder =
        await ref.read(reminderRepositoryProvider).watchForTask(taskId).first;
    if (!mounted) return;
    setState(() {
      _existingReminder = reminder;
      _reminderEnabled = reminder?.isEnabled ?? false;
      _reminderOffsetMinutes = reminder?.offsetMinutes ?? 0;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickRepeatEndDate() async {
    final base = _dueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _repeatEndDate ?? base,
      firstDate: base,
      lastDate: DateTime(base.year + 10),
    );
    if (picked != null) setState(() => _repeatEndDate = picked);
  }

  void _setRepeatEnabled(bool enabled) {
    setState(() {
      _repeatEnabled = enabled;
      if (enabled) _dueDate ??= DateTime.now();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final categoryId = _categoryId;
    if (categoryId == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final recurrenceRuleId = await _saveRecurrenceRule();

    int taskId;
    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
        categoryId: categoryId,
        dueDate: _dueDate,
        recurrenceRuleId: recurrenceRuleId,
      );
      taskId = updated.id;
      await ref.read(updateTaskUseCaseProvider).call(updated);
    } else {
      taskId = await ref.read(createTaskUseCaseProvider).call(
            title: title,
            description: description.isEmpty ? null : description,
            categoryId: categoryId,
            dueDate: _dueDate,
            recurrenceRuleId: recurrenceRuleId,
          );
    }

    await _saveReminder(taskId);

    // A task/reminder just changed, so resync scheduled notifications
    // immediately instead of waiting for the next app boot.
    await ref.read(reminderSchedulingServiceProvider).run();

    if (mounted) Navigator.of(context).pop();
  }

  /// Creates, updates, or deletes the task's recurrence rule to match the
  /// form state, returning the id to store on the task (or null).
  Future<int?> _saveRecurrenceRule() async {
    final existingRuleId = widget.task?.recurrenceRuleId;

    if (!_repeatEnabled) {
      if (existingRuleId != null) {
        await ref.read(deleteRecurrenceRuleUseCaseProvider).call(existingRuleId);
      }
      return null;
    }

    final startDate = _dueDate ?? DateTime.now();
    final byWeekdays =
        _frequency == RecurrenceFrequency.weekly && _selectedWeekdays.isNotEmpty
            ? _selectedWeekdays.toList()
            : null;

    if (existingRuleId == null) {
      return ref.read(createRecurrenceRuleUseCaseProvider).call(
            frequency: _frequency,
            interval: _interval,
            byWeekdays: byWeekdays,
            startDate: startDate,
            endDate: _repeatEndDate,
          );
    }

    await ref.read(updateRecurrenceRuleUseCaseProvider).call(
          RecurrenceRule(
            id: existingRuleId,
            frequency: _frequency,
            interval: _interval,
            byWeekdays: byWeekdays,
            startDate: startDate,
            endDate: _repeatEndDate,
          ),
        );
    return existingRuleId;
  }

  Future<void> _saveReminder(int taskId) async {
    if (!_reminderEnabled) {
      if (_existingReminder != null) {
        await ref.read(deleteReminderUseCaseProvider).call(_existingReminder!.id);
      }
      return;
    }

    if (_existingReminder == null) {
      await ref.read(createReminderUseCaseProvider).call(
            taskId: taskId,
            offsetMinutes: _reminderOffsetMinutes,
          );
    } else {
      await ref.read(updateReminderUseCaseProvider).call(
            Reminder(
              id: _existingReminder!.id,
              taskId: taskId,
              offsetMinutes: _reminderOffsetMinutes,
              isEnabled: true,
              createdAt: _existingReminder!.createdAt,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesListProvider());

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTask : l10n.addTask),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.taskTitle),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: l10n.taskDescription),
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int>(
                initialValue: categories.any((c) => c.id == _categoryId)
                    ? _categoryId
                    : null,
                decoration: InputDecoration(labelText: l10n.taskCategory),
                items: [
                  for (final category in categories)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) =>
                    value == null ? l10n.requiredField : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text('$error'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.taskDueDate),
              subtitle: Text(
                _dueDate == null
                    ? l10n.noDueDate
                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickDueDate,
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.taskRepeat),
              value: _repeatEnabled,
              onChanged: _setRepeatEnabled,
            ),
            if (_repeatEnabled) ..._buildRepeatFields(l10n),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.taskReminder),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (_reminderEnabled)
              DropdownButtonFormField<int>(
                initialValue: _reminderOffsetMinutes,
                items: [
                  for (final minutes in _reminderOffsetOptions)
                    DropdownMenuItem(
                      value: minutes,
                      child: Text(_reminderOffsetLabel(l10n, minutes)),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _reminderOffsetMinutes = value ?? 0),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRepeatFields(AppLocalizations l10n) {
    return [
      const SizedBox(height: 8),
      SegmentedButton<RecurrenceFrequency>(
        segments: [
          ButtonSegment(
            value: RecurrenceFrequency.daily,
            label: Text(l10n.recurrenceFrequencyDaily),
          ),
          ButtonSegment(
            value: RecurrenceFrequency.weekly,
            label: Text(l10n.recurrenceFrequencyWeekly),
          ),
          ButtonSegment(
            value: RecurrenceFrequency.monthly,
            label: Text(l10n.recurrenceFrequencyMonthly),
          ),
        ],
        selected: {_frequency},
        onSelectionChanged: (selection) =>
            setState(() => _frequency = selection.first),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Text(l10n.recurrenceEvery),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _interval > 1
                ? () => setState(() => _interval -= 1)
                : null,
          ),
          Text('$_interval', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _interval < 30
                ? () => setState(() => _interval += 1)
                : null,
          ),
          Text(_intervalUnitLabel(l10n)),
        ],
      ),
      if (_frequency == RecurrenceFrequency.weekly) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final weekday in const [1, 2, 3, 4, 5, 6, 7])
              FilterChip(
                label: Text(_weekdayLabel(l10n, weekday)),
                selected: _selectedWeekdays.contains(weekday),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _selectedWeekdays.add(weekday);
                  } else {
                    _selectedWeekdays.remove(weekday);
                  }
                }),
              ),
          ],
        ),
      ],
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.recurrenceEndDate),
        subtitle: Text(
          _repeatEndDate == null
              ? l10n.recurrenceNoEndDate
              : '${_repeatEndDate!.day}/${_repeatEndDate!.month}/${_repeatEndDate!.year}',
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_calendar_outlined),
              onPressed: _pickRepeatEndDate,
            ),
            if (_repeatEndDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _repeatEndDate = null),
              ),
          ],
        ),
      ),
    ];
  }

  String _intervalUnitLabel(AppLocalizations l10n) {
    switch (_frequency) {
      case RecurrenceFrequency.daily:
        return l10n.recurrenceIntervalUnitDaily(_interval);
      case RecurrenceFrequency.weekly:
        return l10n.recurrenceIntervalUnitWeekly(_interval);
      case RecurrenceFrequency.monthly:
        return l10n.recurrenceIntervalUnitMonthly(_interval);
    }
  }

  String _weekdayLabel(AppLocalizations l10n, int isoWeekday) {
    switch (isoWeekday) {
      case 1:
        return l10n.recurrenceWeekdayMon;
      case 2:
        return l10n.recurrenceWeekdayTue;
      case 3:
        return l10n.recurrenceWeekdayWed;
      case 4:
        return l10n.recurrenceWeekdayThu;
      case 5:
        return l10n.recurrenceWeekdayFri;
      case 6:
        return l10n.recurrenceWeekdaySat;
      default:
        return l10n.recurrenceWeekdaySun;
    }
  }

  String _reminderOffsetLabel(AppLocalizations l10n, int minutes) {
    switch (minutes) {
      case 0:
        return l10n.reminderOffsetAtTime;
      case 10:
        return l10n.reminderOffset10;
      case 30:
        return l10n.reminderOffset30;
      case 60:
        return l10n.reminderOffset60;
      default:
        return l10n.reminderOffset1440;
    }
  }
}
