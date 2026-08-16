import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStats)),
      body: EmptyState(icon: Icons.bar_chart_outlined, message: l10n.comingSoon),
    );
  }
}
