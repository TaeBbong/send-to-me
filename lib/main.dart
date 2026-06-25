import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/dev/dev_bootstrap.dart';
import 'core/env/env.dart';
import 'core/firebase/firebase_init.dart';
import 'core/firebase/firebase_status.dart';
import 'core/providers/app_providers.dart';
import 'features/classification/classification_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko');
  final prefs = await SharedPreferences.getInstance();
  final firebaseReady = await tryInitializeFirebase();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
    ],
  );

  // In development, replay onboarding and seed sample data into an empty DB so
  // a fresh install is immediately testable. No-op in release.
  if (Env.isDev) {
    await runDevBootstrap(container, prefs);
  }

  // Resume classification for any memos left pending from a previous run.
  // (Periodic background re-classification is disabled for now — draft memos
  // are re-classified on demand via the draft room's "전체 재분류" action.)
  if (firebaseReady) {
    unawaited(container.read(classificationWorkerProvider).processPending());
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AwesomeMemoApp(),
    ),
  );
}
