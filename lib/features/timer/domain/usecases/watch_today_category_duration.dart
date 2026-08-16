import '../repositories/timer_repository.dart';

class WatchTodayCategoryDuration {
  const WatchTodayCategoryDuration(this._repository);

  final TimerRepository _repository;

  Stream<int> call(int categoryId) =>
      _repository.watchTodayDurationSecondsForCategory(categoryId);
}
