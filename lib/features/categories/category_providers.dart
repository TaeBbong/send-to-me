import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/app_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';

const _uuid = Uuid();

/// All visible categories (chat rooms), most-recently-active first.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Hidden categories, most-recently-active first. Backs the hidden-rooms view
/// and the "숨겨진 채팅방" entry row on the main list.
final archivedCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchArchived(),
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

/// Imperative category operations (rename / hide / unhide / delete) from the UI.
class CategoryActions {
  CategoryActions(this._ref);
  final Ref _ref;

  Future<void> rename(Category category, String name) => _ref
      .read(categoryRepositoryProvider)
      .update(category.copyWith(name: name, updatedAt: DateTime.now()));

  Future<void> archive(String id) =>
      _ref.read(categoryRepositoryProvider).archive(id);

  Future<void> unarchive(String id) =>
      _ref.read(categoryRepositoryProvider).unarchive(id);

  Future<void> delete(String id) =>
      _ref.read(categoryRepositoryProvider).delete(id);

  /// Creates a category the user defined by hand. Falls back to the kind's
  /// default emoji when none is supplied.
  Future<Category> create({
    required String name,
    required CategoryKind kind,
    String? emoji,
    String? description,
  }) async {
    final now = DateTime.now();
    final trimmedEmoji = emoji?.trim() ?? '';
    final category = Category(
      id: _uuid.v4(),
      name: name.trim(),
      emoji: trimmedEmoji.isEmpty ? kind.defaultEmoji : trimmedEmoji,
      kind: kind,
      description: description?.trim() ?? '',
      createdAt: now,
      updatedAt: now,
    );
    await _ref.read(categoryRepositoryProvider).add(category);
    return category;
  }
}
