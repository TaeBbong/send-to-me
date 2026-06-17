import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/memo_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/memo_repository.dart';

/// Bound at startup in `main()` via [ProviderScope.overrides] once the async
/// [SharedPreferences] instance is loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// The single Drift database instance for the app lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final memoRepositoryProvider = Provider<MemoRepository>(
  (ref) => MemoRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(appDatabaseProvider)),
);
