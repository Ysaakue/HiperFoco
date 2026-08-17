import 'package:clock/clock.dart';

import '../repositories/archive_state_repository.dart';
import '../repositories/timer_repository.dart';

/// Runs once per app boot: archives every local calendar day between the
/// last run and yesterday (inclusive), then purges history past the
/// configured retention window. Safe to call even if the app was closed for
/// days, weeks, or was never opened before.
class DailyArchiveService {
  const DailyArchiveService(this._timerRepository, this._archiveStateRepository);

  final TimerRepository _timerRepository;
  final ArchiveStateRepository _archiveStateRepository;

  Future<void> run() async {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastArchived = _archiveStateRepository.getLastArchivedDate();
    var cursor = lastArchived == null
        ? today
        : DateTime(lastArchived.year, lastArchived.month, lastArchived.day)
            .add(const Duration(days: 1));

    while (cursor.isBefore(today)) {
      await _timerRepository.archiveDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    await _archiveStateRepository.setLastArchivedDate(today);

    final retentionMonths = _archiveStateRepository.getRetentionMonths();
    await _timerRepository.purgeHistoryOlderThan(retentionMonths);
  }
}
