import '../repositories/timer_repository.dart';

class StopTimer {
  const StopTimer(this._repository);

  final TimerRepository _repository;

  Future<void> call(int sessionId) => _repository.stop(sessionId);
}
