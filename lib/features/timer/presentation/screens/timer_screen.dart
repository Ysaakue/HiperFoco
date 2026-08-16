import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_icons.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/timer_session.dart';
import '../providers/timer_providers.dart';
import 'timer_history_screen.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only pop on a genuine *transition* from having an active session to
    // not having one (a real stop). Right after this screen is pushed —
    // typically straight after StartTimer/ResumeTimer commits the write —
    // the stream can still briefly hold its previous "null" value until the
    // watch query catches up; reacting to that transient null here (rather
    // than via `data: (session) { if (session == null) ... }` below) avoids
    // bouncing straight back out before the real session ever renders.
    ref.listen<AsyncValue<TimerSession?>>(activeTimerSessionProvider,
        (previous, next) {
      final hadSession = previous?.valueOrNull != null;
      if (hadSession && next.valueOrNull == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    final sessionAsync = ref.watch(activeTimerSessionProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _ActiveTimerView(session: session, now: _now);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('$error'))),
    );
  }
}

class _ActiveTimerView extends ConsumerWidget {
  const _ActiveTimerView({required this.session, required this.now});

  final TimerSession session;
  final DateTime now;

  int get _liveDeltaSeconds {
    final openStart = session.currentIntervalStartedAt;
    if (!session.isRunning || openStart == null) return 0;
    return now.difference(openStart).inSeconds;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoryAsync = ref.watch(categoryByIdProvider(session.categoryId));
    final todayCategoryAsync =
        ref.watch(todayCategoryDurationSecondsProvider(session.categoryId));
    final todayTotalAsync = ref.watch(todayTotalDurationSecondsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final category = categoryAsync.valueOrNull;
    final color = category != null
        ? Color(category.colorValue)
        : colorScheme.primary;
    final icon =
        category != null ? CategoryIcons.resolve(category.iconKey) : Icons.timer_outlined;

    final todayCategorySeconds =
        (todayCategoryAsync.valueOrNull ?? 0) + _liveDeltaSeconds;
    final todayTotalSeconds =
        (todayTotalAsync.valueOrNull ?? 0) + _liveDeltaSeconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.timerHistory,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TimerHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            session.isRunning ? l10n.timerRunning : l10n.timerPaused,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            DurationFormatter.hms(session.elapsedAt(now)),
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Icon(icon, size: 56, color: color),
          const Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Metric(
                label: l10n.timerTodayCategory,
                value: DurationFormatter.hms(Duration(seconds: todayCategorySeconds)),
              ),
              _Metric(
                label: l10n.timerTodayTotal,
                value: DurationFormatter.hms(Duration(seconds: todayTotalSeconds)),
              ),
            ],
          ),
          const Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                tooltip: l10n.timerStop,
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: () async {
                  await ref.read(stopTimerUseCaseProvider).call(session.id);
                },
              ),
              const SizedBox(width: 32),
              IconButton.filled(
                iconSize: 40,
                padding: const EdgeInsets.all(20),
                tooltip: session.isRunning ? l10n.timerPause : l10n.timerResume,
                icon: Icon(session.isRunning ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (session.isRunning) {
                    ref.read(pauseTimerUseCaseProvider).call(session.id);
                  } else {
                    ref.read(resumeTimerUseCaseProvider).call(session.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colorScheme.outline),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
