abstract interface class ArchiveStateRepository {
  /// The last local calendar day (midnight-normalized) the archive job
  /// finished processing, or null if it has never run.
  DateTime? getLastArchivedDate();

  Future<void> setLastArchivedDate(DateTime date);

  /// How many months of archived history to keep. Defaults to 6.
  int getRetentionMonths();

  Future<void> setRetentionMonths(int months);
}
