import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/features/goals/domain/entities/goal.dart';

void main() {
  Goal goal() {
    return Goal(
      id: 1,
      title: 'Learn Flutter',
      description: 'Build a real app end to end',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  group('copyWith', () {
    test('omitting a field keeps its current value', () {
      final updated = goal().copyWith(updatedAt: DateTime(2026, 2, 1));

      expect(updated.title, 'Learn Flutter');
      expect(updated.description, 'Build a real app end to end');
    });

    test('explicitly passing null clears the description', () {
      final updated = goal().copyWith(description: null);

      expect(updated.description, isNull);
    });

    test('passing a new value replaces the old one', () {
      final updated = goal().copyWith(
        title: 'Master Flutter',
        description: 'Revised scope',
      );

      expect(updated.title, 'Master Flutter');
      expect(updated.description, 'Revised scope');
    });

    test('id and createdAt are never changed by copyWith', () {
      final updated = goal().copyWith(title: 'New title');

      expect(updated.id, 1);
      expect(updated.createdAt, DateTime(2026, 1, 1));
    });
  });
}
