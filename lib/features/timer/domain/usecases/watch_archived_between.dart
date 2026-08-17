import '../entities/timer_history_entry.dart';
import '../repositories/timer_repository.dart';

class WatchArchivedBetween {
  const WatchArchivedBetween(this._repository);

  final TimerRepository _repository;

  Stream<List<TimerHistoryEntry>> call(DateTime start, DateTime end) =>
      _repository.watchArchivedBetween(start, end);
}
