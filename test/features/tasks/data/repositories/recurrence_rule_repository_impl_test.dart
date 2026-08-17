import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/features/tasks/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_frequency.dart';
import 'package:hiperfoco/features/tasks/domain/entities/recurrence_rule.dart';

void main() {
  late AppDatabase database;
  late RecurrenceRuleRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = RecurrenceRuleRepositoryImpl(database.recurrenceRuleDao);
  });

  tearDown(() => database.close());

  test('create persists a rule with weekdays encoded and decoded round-trip',
      () async {
    final id = await repository.create(
      frequency: RecurrenceFrequency.weekly,
      interval: 2,
      byWeekdays: [1, 3, 5],
      startDate: DateTime(2026, 3, 2),
      endDate: DateTime(2026, 6, 1),
    );

    final rule = await repository.getById(id);

    expect(rule, isNotNull);
    expect(rule!.frequency, RecurrenceFrequency.weekly);
    expect(rule.interval, 2);
    expect(rule.byWeekdays, [1, 3, 5]);
    expect(rule.startDate, DateTime(2026, 3, 2));
    expect(rule.endDate, DateTime(2026, 6, 1));
  });

  test('create with no weekdays/monthDay/endDate leaves them null', () async {
    final id = await repository.create(
      frequency: RecurrenceFrequency.daily,
      startDate: DateTime(2026, 3, 1),
    );

    final rule = await repository.getById(id);

    expect(rule!.byWeekdays, isNull);
    expect(rule.byMonthDay, isNull);
    expect(rule.endDate, isNull);
    expect(rule.interval, 1);
  });

  test('update replaces every field', () async {
    final id = await repository.create(
      frequency: RecurrenceFrequency.daily,
      startDate: DateTime(2026, 3, 1),
    );
    final rule = await repository.getById(id);

    await repository.update(
      RecurrenceRule(
        id: id,
        frequency: RecurrenceFrequency.monthly,
        interval: 3,
        byMonthDay: 15,
        startDate: rule!.startDate,
        endDate: DateTime(2027, 1, 1),
      ),
    );

    final updated = await repository.getById(id);
    expect(updated!.frequency, RecurrenceFrequency.monthly);
    expect(updated.interval, 3);
    expect(updated.byMonthDay, 15);
    expect(updated.endDate, DateTime(2027, 1, 1));
  });

  test('delete removes the rule', () async {
    final id = await repository.create(
      frequency: RecurrenceFrequency.daily,
      startDate: DateTime(2026, 3, 1),
    );

    await repository.delete(id);

    expect(await repository.getById(id), isNull);
  });

  test('getById returns null for an unknown id', () async {
    expect(await repository.getById(999), isNull);
  });
}
