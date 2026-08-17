import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiperfoco/core/database/app_database.dart';

/// A throwaway database with no declared tables, used only to run raw SQL
/// against a file through Drift's normal open lifecycle (a bare
/// `NativeDatabase.runCustom` call fails with "ensureOpen() not called" —
/// that lifecycle is normally handled by a `GeneratedDatabase` wrapper).
class _RawSetup extends GeneratedDatabase {
  _RawSetup(super.executor);

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  int get schemaVersion => 1;
}

/// Regression test for a real bug found during M4 manual QA: opening the
/// app against an on-disk database created by an older schema version threw
/// `SqliteException: table tasks has no column named recurrence_rule_id`.
///
/// `MigrationStrategy.onUpgrade`'s original `createAll()`-only body looked
/// "destructive enough" for a pre-release app with no data worth keeping,
/// but `createAll()` only issues `CREATE TABLE IF NOT EXISTS` — it never
/// alters a table that already exists, so an old `tasks` table missing the
/// new `recurrence_rule_id` column survived untouched and crashed the very
/// first query against it. This test simulates exactly that scenario
/// against a real on-disk file (not `.memory()`, since the bug is about
/// migrating an *existing* file) — a v4-shaped database opened through the
/// current (v5) schema must not throw and must have the new column.
void main() {
  test('opening a v4-schema database file through the v5 schema does not '
      'crash and rebuilds the new columns', () async {
    final file = File(
      '${Directory.systemTemp.path}/hiperfoco_migration_test_'
      '${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    // Simulate a device that already has the pre-M4 (v4) schema installed:
    // a `tasks` table with no `recurrence_rule_id` column.
    final oldDb = _RawSetup(NativeDatabase(file));
    await oldDb.customStatement('''
      CREATE TABLE categories (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon_key TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
    await oldDb.customStatement('''
      CREATE TABLE tasks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NULL,
        category_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        due_date INTEGER NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER NULL
      )
    ''');
    await oldDb.customStatement('PRAGMA user_version = 4');
    await oldDb.close();

    // Open the same file through the real (v5) schema, as the app would on
    // its next launch.
    final database = AppDatabase.forTesting(NativeDatabase(file));

    final categoryId = await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'Work',
            colorValue: 0xFF7C5CFC,
            iconKey: 'work',
          ),
        );
    final taskId = await database.into(database.tasks).insert(
          TasksCompanion.insert(
            title: 'Water plants',
            categoryId: categoryId,
            recurrenceRuleId: const Value(null),
          ),
        );

    final task = await (database.select(database.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingle();
    expect(task.title, 'Water plants');
    expect(task.recurrenceRuleId, isNull);

    await database.close();
  });
}
