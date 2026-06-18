import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/memo.dart';

/// All visible categories (chat rooms), most-recently-active first.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Memos inside a single category, in chat order (oldest first).
final memosByCategoryProvider = StreamProvider.family<List<Memo>, String>(
  (ref, categoryId) =>
      ref.watch(memoRepositoryProvider).watchByCategory(categoryId),
);

/// Looks up a single category from the cached [categoriesProvider] stream.
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
  for (final c in categories) {
    if (c.id == id) return c;
  }
  return null;
});

final categoryActionsProvider = Provider<CategoryActions>(CategoryActions.new);

/// Imperative category operations (rename / archive / delete) from the UI.
class CategoryActions {
  CategoryActions(this._ref);
  final Ref _ref;

  Future<void> rename(Category category, String name) => _ref
      .read(categoryRepositoryProvider)
      .update(category.copyWith(name: name, updatedAt: DateTime.now()));

  Future<void> archive(String id) =>
      _ref.read(categoryRepositoryProvider).archive(id);

  Future<void> delete(String id) =>
      _ref.read(categoryRepositoryProvider).delete(id);
}
