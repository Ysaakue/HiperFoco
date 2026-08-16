import '../repositories/timer_repository.dart';

class ResumeTimer {
  const ResumeTimer(this._repository);

  final TimerRepository _repository;

  Future<void> call(int sessionId) => _repository.resume(sessionId);
}
