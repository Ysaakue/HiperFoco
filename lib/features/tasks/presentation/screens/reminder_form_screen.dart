import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/recurrence_frequency.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/reminder.dart';
import '../providers/task_providers.dart';

class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({this.reminder, super.key});

  final Reminder? reminder;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  late final TextEditingController _messageController;
  bool _repeats = false;
  DateTime _anchor = DateTime.now().add(const Duration(hours: 1));
  RecurrenceFrequency _frequency = RecurrenceFrequency.daily;
  int _interval = 1;
  DateTime? _endDate;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _messageController = TextEditingController(text: reminder?.message ?? '');

    if (reminder != null && reminder.recurrenceRuleId != null) {
      _repeats = true;
      _loadExistingRule(reminder.recurrenceRuleId!);
    } else if (reminder != null && reminder.scheduledAt != null) {
      _anchor = reminder.scheduledAt!;
    }
  }

  Future<void> _loadExistingRule(int ruleId) async {
    final rule = await ref.read(recurrenceRuleRepositoryProvider).getById(ruleId);
    if (!mounted || rule == null) return;
    setState(() {
      _anchor = rule.startDate;
      _frequency = rule.frequency;
      _interval = rule.interval;
      _endDate = rule.endDate;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickAnchor() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_anchor),
    );
    if (time == null) return;
    setState(() {
      _anchor = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _anchor,
      firstDate: _anchor,
      lastDate: DateTime(_anchor.year + 10),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final message = _messageController.text.trim();
    final existing = widget.reminder;

    int? recurrenceRuleId;
    if (_repeats) {
      final existingRuleId = existing?.recurrenceRuleId;
      if (existingRuleId == null) {
        recurrenceRuleId = await ref.read(createRecurrenceRuleUseCaseProvider).call(
              frequency: _frequency,
              interval: _interval,
              startDate: _anchor,
              endDate: _endDate,
            );
      } else {
        recurrenceRuleId = existingRuleId;
        await ref.read(updateRecurrenceRuleUseCaseProvider).call(
              RecurrenceRule(
                id: existingRuleId,
                frequency: _frequency,
                interval: _interval,
                startDate: _anchor,
                endDate: _endDate,
              ),
            );
      }
    } else if (existing?.recurrenceRuleId != null) {
      await ref.read(deleteRecurrenceRuleUseCaseProvider).call(existing!.recurrenceRuleId!);
    }

    if (_isEditing) {
      await ref.read(updateReminderUseCaseProvider).call(
            Reminder(
              id: existing!.id,
              recurrenceRuleId: recurrenceRuleId,
              scheduledAt: _repeats ? null : _anchor,
              offsetMinutes: 0,
              message: message.isEmpty ? null : message,
              isEnabled: true,
              createdAt: existing.createdAt,
            ),
          );
    } else {
      await ref.read(createReminderUseCaseProvider).call(
            recurrenceRuleId: recurrenceRuleId,
            scheduledAt: _repeats ? null : _anchor,
            message: message.isEmpty ? null : message,
          );
    }

    await ref.read(reminderSchedulingServiceProvider).run();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editReminder : l10n.addReminder),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _messageController,
            decoration: InputDecoration(labelText: l10n.reminderMessage),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.taskRepeat),
            value: _repeats,
            onChanged: (value) => setState(() => _repeats = value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.reminderScheduledAt),
            subtitle: Text(_formatDateTime(_anchor)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_calendar_outlined),
              onPressed: _pickAnchor,
            ),
          ),
          if (_repeats) ...[
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
                  onPressed:
                      _interval > 1 ? () => setState(() => _interval -= 1) : null,
                ),
                Text('$_interval', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed:
                      _interval < 30 ? () => setState(() => _interval += 1) : null,
                ),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recurrenceEndDate),
              subtitle: Text(
                _endDate == null
                    ? l10n.recurrenceNoEndDate
                    : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickEndDate,
                  ),
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }
}
