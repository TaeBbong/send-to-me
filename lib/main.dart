import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
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

  // Resume classification for any memos left pending from a previous run.
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
