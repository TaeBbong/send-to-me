import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'category.freezed.dart';

/// A user's classification bucket, presented in the UI as a messenger "chat
/// room". Categories are created by the LLM on demand (when no existing
/// category fits an incoming memo) and matched against on subsequent memos.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String emoji,
    required CategoryKind kind,

    /// A one-line semantic description of what belongs here. This is fed to the
    /// classifier so it can match future memos against existing categories.
    required String description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool archived,
  }) = _Category;

  const Category._();
}
