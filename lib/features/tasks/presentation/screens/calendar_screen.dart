import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCalendar)),
      body: EmptyState(
          icon: Icons.calendar_month_outlined, message: l10n.comingSoon),
    );
  }
}
