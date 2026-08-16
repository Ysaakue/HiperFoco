import '../repositories/timer_repository.dart';

class PauseTimer {
  const PauseTimer(this._repository);

  final TimerRepository _repository;

  Future<void> call(int sessionId) => _repository.pause(sessionId);
}
