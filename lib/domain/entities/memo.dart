import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'memo.freezed.dart';

/// A single memo the user "tossed" into the note-to-self chat.
///
/// A memo is saved immediately ([MemoStatus.pending]) and later enriched by the
/// background classifier: assigned a [categoryId], optionally given a [summary]
/// (for reference-type content) and a detected [sourceUrl].
@freezed
abstract class Memo with _$Memo {
  const factory Memo({
    required String id,
    required String content,
    required MemoStatus status,
    required DateTime createdAt,

    /// Assigned by the classifier; null while pending/failed.
    String? categoryId,

    /// Optional LLM-generated summary (mainly for reference/link memos).
    String? summary,

    /// First URL detected in [content], if any.
    String? sourceUrl,

    /// Checklist state, meaningful when the memo lives in a TODO category.
    @Default(false) bool isDone,

    /// When the memo was checked off ([isDone] flipped to true); cleared when
    /// unchecked. Lets a TODO room show both registered and completed times.
    DateTime? doneAt,

    /// Optional due date the classifier may extract from the text.
    DateTime? dueAt,

    /// When the memo was successfully classified.
    DateTime? classifiedAt,

    /// Page title fetched for [sourceUrl] (og:title / <title>), so a reference
    /// card can show what the link actually is rather than just its host.
    String? linkTitle,
  }) = _Memo;

  const Memo._();

  /// Whether this memo still needs (or is undergoing) classification.
  bool get isAwaitingClassification =>
      status == MemoStatus.pending || status == MemoStatus.processing;
}
