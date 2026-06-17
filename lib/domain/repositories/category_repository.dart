import '../../core/error/result.dart';
import '../entities/category.dart';

/// Persistence contract for categories ("chat rooms").
abstract interface class CategoryRepository {
  /// All non-archived categories, as a reactive stream.
  Stream<List<Category>> watchAll();

  /// One-shot read of all categories — used by the classifier to decide
  /// whether an incoming memo matches an existing bucket.
  Future<Result<List<Category>>> getAll();

  Future<Result<Category?>> getById(String id);

  Future<Result<Category>> add(Category category);

  Future<Result<void>> update(Category category);

  /// Archive (soft-delete) a category. Memos keep their reference but the room
  /// disappears from the list.
  Future<Result<void>> archive(String id);

  Future<Result<void>> delete(String id);
}
