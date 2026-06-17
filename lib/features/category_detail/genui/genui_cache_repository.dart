import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/local/app_database.dart';

/// A cached generative-UI render for one category.
class GenUiCacheEntry {
  const GenUiCacheEntry({required this.payload, required this.signature});

  /// Raw A2UI protocol text previously produced by the model.
  final String payload;

  /// Signature of the memo set the [payload] was generated from.
  final String signature;
}

/// Stores/loads the per-category generative-UI output so a room's AI layout is
/// built once and replayed afterwards instead of re-calling the LLM.
class GenUiCacheRepository {
  GenUiCacheRepository(this._db);

  final AppDatabase _db;

  Future<GenUiCacheEntry?> get(String categoryId) async {
    final row = await (_db.select(_db.genUiCaches)
          ..where((t) => t.categoryId.equals(categoryId)))
        .getSingleOrNull();
    if (row == null) return null;
    return GenUiCacheEntry(payload: row.payload, signature: row.signature);
  }

  Future<void> save(String categoryId, String payload, String signature) {
    return _db.into(_db.genUiCaches).insertOnConflictUpdate(
      GenUiCachesCompanion(
        categoryId: Value(categoryId),
        payload: Value(payload),
        signature: Value(signature),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clear(String categoryId) {
    return (_db.delete(_db.genUiCaches)
          ..where((t) => t.categoryId.equals(categoryId)))
        .go();
  }
}

final genUiCacheRepositoryProvider = Provider<GenUiCacheRepository>(
  (ref) => GenUiCacheRepository(ref.watch(appDatabaseProvider)),
);
