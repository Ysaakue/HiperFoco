import '../repositories/timer_repository.dart';

class PurgeOldData {
  const PurgeOldData(this._repository);

  final TimerRepository _repository;

  Future<void> call({required int olderThanMonths}) =>
      _repository.purgeHistoryOlderThan(olderThanMonths);
}
