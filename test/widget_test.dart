import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hiperfoco/app/app.dart';
import 'package:hiperfoco/core/database/app_database.dart';
import 'package:hiperfoco/core/database/database_providers.dart';
import 'package:hiperfoco/features/settings/presentation/providers/settings_providers.dart';

void main() {
  testWidgets('App shell renders bottom navigation destinations',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const HiperFocoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    // Drift's query streams schedule a zero-duration cleanup Timer when their
    // last listener is cancelled; forcing disposal here (instead of letting
    // flutter_test's default teardown do it after the test body returns)
    // keeps that timer from being flagged as still pending.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
