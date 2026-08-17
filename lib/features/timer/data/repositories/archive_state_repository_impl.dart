import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/archive_state_repository.dart';

class ArchiveStateRepositoryImpl implements ArchiveStateRepository {
  ArchiveStateRepositoryImpl(this._preferences);

  static const _lastArchivedDateKey = 'archive.last_archived_date';
  static const _retentionMonthsKey = 'archive.retention_months';
  static const defaultRetentionMonths = 6;

  final SharedPreferences _preferences;

  @override
  DateTime? getLastArchivedDate() {
    final value = _preferences.getString(_lastArchivedDateKey);
    if (value == null) return null;
    return DateTime.parse(value);
  }

  @override
  Future<void> setLastArchivedDate(DateTime date) {
    return _preferences.setString(
      _lastArchivedDateKey,
      date.toIso8601String(),
    );
  }

  @override
  int getRetentionMonths() {
    return _preferences.getInt(_retentionMonthsKey) ?? defaultRetentionMonths;
  }

  @override
  Future<void> setRetentionMonths(int months) {
    return _preferences.setInt(_retentionMonthsKey, months);
  }
}
