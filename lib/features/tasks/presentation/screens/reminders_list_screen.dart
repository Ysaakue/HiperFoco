import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reminder.dart';
import '../providers/task_providers.dart';
import 'reminder_form_screen.dart';

class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final remindersAsync = ref.watch(standaloneRemindersListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_outlined,
              message: l10n.noRemindersYet,
            );
          }
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _ReminderTile(
                reminder: reminder,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReminderFormScreen(reminder: reminder),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.deleteReminder,
                    message: l10n.deleteReminderConfirm,
                    confirmLabel: l10n.delete,
                    cancelLabel: l10n.cancel,
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await ref.read(deleteReminderUseCaseProvider).call(reminder.id);
                    await ref.read(reminderSchedulingServiceProvider).run();
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReminderFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({
    required this.reminder,
    required this.onTap,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      onTap: onTap,
      leading: Icon(reminder.isRecurring ? Icons.repeat : Icons.notifications_outlined),
      title: Text(reminder.message?.isNotEmpty == true ? reminder.message! : '—'),
      subtitle: reminder.isRecurring
          ? Consumer(
              builder: (context, ref, _) {
                final ruleAsync =
                    ref.watch(recurrenceRuleByIdProvider(reminder.recurrenceRuleId!));
                final rule = ruleAsync.valueOrNull;
                if (rule == null) return const SizedBox.shrink();
                return Text(_frequencyLabel(l10n, rule.frequency.name));
              },
            )
          : Text(
              reminder.scheduledAt != null
                  ? _formatDateTime(reminder.scheduledAt!)
                  : '',
            ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }

  String _frequencyLabel(AppLocalizations l10n, String frequency) {
    switch (frequency) {
      case 'daily':
        return l10n.recurrenceFrequencyDaily;
      case 'weekly':
        return l10n.recurrenceFrequencyWeekly;
      default:
        return l10n.recurrenceFrequencyMonthly;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }
}
