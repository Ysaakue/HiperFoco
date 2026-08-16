import '../repositories/timer_repository.dart';

class StartTimer {
  const StartTimer(this._repository);

  final TimerRepository _repository;

  Future<int> call({required int categoryId, int? taskId}) {
    return _repository.start(categoryId: categoryId, taskId: taskId);
  }
}
