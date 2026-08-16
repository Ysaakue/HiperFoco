import '../entities/timer_session.dart';
import '../repositories/timer_repository.dart';

class WatchActiveSession {
  const WatchActiveSession(this._repository);

  final TimerRepository _repository;

  Stream<TimerSession?> call() => _repository.watchActiveSession();
}
