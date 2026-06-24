import '../../core/error/result.dart';
import '../entities/category.dart';

/// Persistence contract for categories ("chat rooms").
abstract interface class CategoryRepository {
  /// All visible (non-hidden) categories, as a reactive stream.
  Stream<List<Category>> watchAll();

  /// All hidden categories, as a reactive stream. Shown in the dedicated
  /// "hidden chat rooms" view so the user can bring them back.
  Stream<List<Category>> watchArchived();

  /// One-shot read of all categories — used by the classifier to decide
  /// whether an incoming memo matches an existing bucket.
  Future<Result<List<Category>>> getAll();

  Future<Result<Category?>> getById(String id);

  Future<Result<Category>> add(Category category);

  Future<Result<void>> update(Category category);

  /// Hide a category. Memos keep their reference but the room disappears from
  /// the main list and moves to the hidden view.
  Future<Result<void>> archive(String id);

  /// Un-hide a category, returning it to the main list.
  Future<Result<void>> unarchive(String id);

  Future<Result<void>> delete(String id);
}
