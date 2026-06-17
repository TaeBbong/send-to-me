import '../../core/error/result.dart';
import '../entities/memo.dart';

/// Persistence contract for memos. Implemented by the data layer (Drift).
abstract interface class MemoRepository {
  /// All memos, newest first, as a reactive stream.
  Stream<List<Memo>> watchAll();

  /// Memos belonging to [categoryId], oldest first (chat order).
  Stream<List<Memo>> watchByCategory(String categoryId);

  /// Memos not yet assigned to any category (the note-to-self timeline also
  /// shows these immediately after capture).
  Stream<List<Memo>> watchUnclassified();

  /// One-shot read of all memos still needing classification.
  Future<Result<List<Memo>>> getPending();

  Future<Result<Memo>> add(Memo memo);

  Future<Result<void>> update(Memo memo);

  Future<Result<void>> delete(String id);

  /// Toggle the checklist state of a memo (todo categories).
  Future<Result<void>> setDone(String id, bool isDone);
}
