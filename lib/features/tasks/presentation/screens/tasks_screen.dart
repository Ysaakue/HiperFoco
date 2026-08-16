import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTasks)),
      body: EmptyState(icon: Icons.checklist_outlined, message: l10n.comingSoon),
    );
  }
}
