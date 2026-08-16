import '../repositories/timer_repository.dart';

class WatchTodayTotalDuration {
  const WatchTodayTotalDuration(this._repository);

  final TimerRepository _repository;

  Stream<int> call() => _repository.watchTodayTotalDurationSeconds();
}
