import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/timer/data/repositories/archive_state_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ArchiveStateRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = ArchiveStateRepositoryImpl(await SharedPreferences.getInstance());
  });

  group('lastArchivedDate', () {
    test('is null when never set', () {
      expect(repository.getLastArchivedDate(), isNull);
    });

    test('round-trips through set/get', () async {
      final date = DateTime(2026, 3, 15);

      await repository.setLastArchivedDate(date);

      expect(repository.getLastArchivedDate(), date);
    });
  });

  group('retentionMonths', () {
    test('defaults to 6 when never set', () {
      expect(repository.getRetentionMonths(), 6);
    });

    test('round-trips through set/get', () async {
      await repository.setRetentionMonths(12);

      expect(repository.getRetentionMonths(), 12);
    });
  });
}
