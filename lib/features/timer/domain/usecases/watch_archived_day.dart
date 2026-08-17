import '../entities/timer_history_entry.dart';
import '../repositories/timer_repository.dart';

class WatchArchivedDay {
  const WatchArchivedDay(this._repository);

  final TimerRepository _repository;

  Stream<List<TimerHistoryEntry>> call(DateTime day) =>
      _repository.watchArchivedDay(day);
}
