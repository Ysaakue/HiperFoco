import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/repositories/timer_repository_impl.dart';
import '../../domain/entities/timer_interval.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/resume_timer.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/stop_timer.dart';
import '../../domain/usecases/watch_active_session.dart';
import '../../domain/usecases/watch_intervals_for_day.dart';
import '../../domain/usecases/watch_today_category_duration.dart';
import '../../domain/usecases/watch_today_total_duration.dart';

part 'timer_providers.g.dart';

@Riverpod(keepAlive: true)
TimerRepository timerRepository(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).timerDao;
  return TimerRepositoryImpl(dao);
}

@riverpod
StartTimer startTimerUseCase(Ref ref) {
  return StartTimer(ref.watch(timerRepositoryProvider));
}

@riverpod
PauseTimer pauseTimerUseCase(Ref ref) {
  return PauseTimer(ref.watch(timerRepositoryProvider));
}

@riverpod
ResumeTimer resumeTimerUseCase(Ref ref) {
  return ResumeTimer(ref.watch(timerRepositoryProvider));
}

@riverpod
StopTimer stopTimerUseCase(Ref ref) {
  return StopTimer(ref.watch(timerRepositoryProvider));
}

@Riverpod(keepAlive: true)
Stream<TimerSession?> activeTimerSession(Ref ref) {
  return WatchActiveSession(ref.watch(timerRepositoryProvider))();
}

@riverpod
Stream<int> todayCategoryDurationSeconds(Ref ref, int categoryId) {
  return WatchTodayCategoryDuration(ref.watch(timerRepositoryProvider))(categoryId);
}

@riverpod
Stream<int> todayTotalDurationSeconds(Ref ref) {
  return WatchTodayTotalDuration(ref.watch(timerRepositoryProvider))();
}

@riverpod
Stream<List<TimerInterval>> intervalsForDay(Ref ref, DateTime day) {
  return WatchIntervalsForDay(ref.watch(timerRepositoryProvider))(day);
}
