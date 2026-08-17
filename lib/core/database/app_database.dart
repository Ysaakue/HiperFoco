import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/tasks/domain/entities/task_status.dart';
import '../../features/timer/domain/entities/timer_session_status.dart';
import 'daos/category_dao.dart';
import 'daos/task_dao.dart';
import 'daos/timer_dao.dart';
import 'tables/categories_table.dart';
import 'tables/tasks_table.dart';
import 'tables/timer_history_daily_table.dart';
import 'tables/timer_intervals_table.dart';
import 'tables/timer_sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Tasks, TimerSessions, TimerIntervals, TimerHistoryDaily],
  daos: [CategoryDao, TaskDao, TimerDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Pre-release app: no persisted data worth preserving yet.
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
