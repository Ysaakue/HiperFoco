import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/timer/domain/repositories/archive_state_repository.dart';
import 'package:hiperfoco/features/timer/domain/repositories/timer_repository.dart';
import 'package:hiperfoco/features/timer/domain/services/daily_archive_service.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

class MockArchiveStateRepository extends Mock implements ArchiveStateRepository {}

void main() {
  late MockTimerRepository timerRepository;
  late MockArchiveStateRepository archiveStateRepository;
  late DailyArchiveService service;

  final today = DateTime(2026, 3, 10);

  setUpAll(() {
    registerFallbackValue(today);
  });

  setUp(() {
    timerRepository = MockTimerRepository();
    archiveStateRepository = MockArchiveStateRepository();
    service = DailyArchiveService(timerRepository, archiveStateRepository);

    when(() => timerRepository.archiveDay(any())).thenAnswer((_) async {});
    when(() => archiveStateRepository.setLastArchivedDate(any()))
        .thenAnswer((_) async {});
    when(() => archiveStateRepository.getRetentionMonths()).thenReturn(6);
    when(() => timerRepository.purgeHistoryOlderThan(any()))
        .thenAnswer((_) async {});
  });

  test('first run ever (no last archived date) archives nothing, just marks '
      'today as the baseline', () async {
    when(() => archiveStateRepository.getLastArchivedDate()).thenReturn(null);

    await withClock(Clock.fixed(today), service.run);

    verifyNever(() => timerRepository.archiveDay(any()));
    verify(() => archiveStateRepository.setLastArchivedDate(today)).called(1);
  });

  test('already up to date archives nothing', () async {
    when(() => archiveStateRepository.getLastArchivedDate()).thenReturn(today);

    await withClock(Clock.fixed(today), service.run);

    verifyNever(() => timerRepository.archiveDay(any()));
    verify(() => archiveStateRepository.setLastArchivedDate(today)).called(1);
  });

  test('one day behind archives exactly yesterday', () async {
    final yesterday = today.subtract(const Duration(days: 1));
    // Archiving already completed through the day before yesterday, so
    // yesterday is the only day still pending.
    when(() => archiveStateRepository.getLastArchivedDate())
        .thenReturn(today.subtract(const Duration(days: 2)));

    await withClock(Clock.fixed(today), service.run);

    verify(() => timerRepository.archiveDay(yesterday)).called(1);
  });

  test('closed for several days catches up on every pending day in order',
      () async {
    final fourDaysAgo = today.subtract(const Duration(days: 4));
    when(() => archiveStateRepository.getLastArchivedDate())
        .thenReturn(fourDaysAgo);

    final archivedDays = <DateTime>[];
    when(() => timerRepository.archiveDay(any())).thenAnswer((invocation) async {
      archivedDays.add(invocation.positionalArguments.first as DateTime);
    });

    await withClock(Clock.fixed(today), service.run);

    expect(archivedDays, [
      today.subtract(const Duration(days: 3)),
      today.subtract(const Duration(days: 2)),
      today.subtract(const Duration(days: 1)),
    ]);
    verify(() => archiveStateRepository.setLastArchivedDate(today)).called(1);
  });

  test('always purges using the configured retention window', () async {
    when(() => archiveStateRepository.getLastArchivedDate()).thenReturn(today);
    when(() => archiveStateRepository.getRetentionMonths()).thenReturn(3);

    await withClock(Clock.fixed(today), service.run);

    verify(() => timerRepository.purgeHistoryOlderThan(3)).called(1);
  });
}
