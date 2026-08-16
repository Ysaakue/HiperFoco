import '../entities/timer_interval.dart';
import '../repositories/timer_repository.dart';

class WatchIntervalsForDay {
  const WatchIntervalsForDay(this._repository);

  final TimerRepository _repository;

  Stream<List<TimerInterval>> call(DateTime day) =>
      _repository.watchIntervalsForDay(day);
}
