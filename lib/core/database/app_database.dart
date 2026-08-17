import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/tasks/domain/entities/occurrence_status.dart';
import '../../features/tasks/domain/entities/recurrence_frequency.dart';
import '../../features/tasks/domain/entities/task_status.dart';
import '../../features/timer/domain/entities/timer_session_status.dart';
import 'daos/category_dao.dart';
import 'daos/goal_dao.dart';
import 'daos/goal_step_dao.dart';
import 'daos/recurrence_rule_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/task_dao.dart';
import 'daos/task_occurrence_override_dao.dart';
import 'daos/timer_dao.dart';
import 'tables/categories_table.dart';
import 'tables/goal_steps_table.dart';
import 'tables/goals_table.dart';
import 'tables/recurrence_rules_table.dart';
import 'tables/reminders_table.dart';
import 'tables/task_occurrence_overrides_table.dart';
import 'tables/tasks_table.dart';
import 'tables/timer_history_daily_table.dart';
import 'tables/timer_intervals_table.dart';
import 'tables/timer_sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Tasks,
    TimerSessions,
    TimerIntervals,
    TimerHistoryDaily,
    RecurrenceRules,
    TaskOccurrenceOverrides,
    Reminders,
    Goals,
    GoalSteps,
  ],
  daos: [
    CategoryDao,
    TaskDao,
    TimerDao,
    RecurrenceRuleDao,
    TaskOccurrenceOverrideDao,
    ReminderDao,
    GoalDao,
    GoalStepDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Pre-release app: no persisted data worth preserving yet. Note
          // that `createAll()` alone is NOT destructive — it only creates
          // tables that don't exist yet (`CREATE TABLE IF NOT EXISTS`) and
          // never alters an existing one, so a real schema change (e.g. M4
          // adding a column to `tasks`) would otherwise crash on any device
          // that already has an older install, instead of being rebuilt.
          // Dropping every table first makes createAll() actually start
          // from scratch.
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'hiperfoco.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
