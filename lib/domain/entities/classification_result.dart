import 'enums.dart';

/// The structured decision returned by the LLM for a single memo.
///
/// Exactly one of two outcomes is expected:
///  * [matchedCategoryId] is non-null  → assign to an existing category, or
///  * [matchedCategoryId] is null      → create a new category described by
///    [newCategoryName] / [newCategoryEmoji] / [newCategoryKind] /
///    [newCategoryDescription].
///
/// Parsing is intentionally lenient: the model occasionally omits or renames
/// fields, so [ClassificationResult.fromJson] never throws on a well-formed
/// map and falls back to sensible defaults.
class ClassificationResult {
  const ClassificationResult({
    this.matchedCategoryId,
    this.newCategoryName,
    this.newCategoryEmoji,
    this.newCategoryKind,
    this.newCategoryDescription,
    this.summary,
    this.sourceUrl,
    this.isDone = false,
    this.dueAt,
  });

  /// Id of an existing category the memo matches, or null to create a new one.
  final String? matchedCategoryId;

  final String? newCategoryName;
  final String? newCategoryEmoji;
  final CategoryKind? newCategoryKind;
  final String? newCategoryDescription;

  /// Optional one or two sentence summary (mainly for reference/link memos).
  final String? summary;

  /// A URL extracted from the memo, if relevant.
  final String? sourceUrl;

  /// For todo-like memos, whether it already reads as completed.
  final bool isDone;

  /// An optional due date (ISO-8601) extracted from the text.
  final DateTime? dueAt;

  bool get createsNewCategory =>
      matchedCategoryId == null || matchedCategoryId!.isEmpty;

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final v = json[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    DateTime? parseDate(String? raw) {
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    }

    return ClassificationResult(
      matchedCategoryId: str('matchedCategoryId'),
      newCategoryName: str('newCategoryName'),
      newCategoryEmoji: str('newCategoryEmoji'),
      newCategoryKind: json['newCategoryKind'] == null
          ? null
          : CategoryKind.fromName(str('newCategoryKind')),
      newCategoryDescription: str('newCategoryDescription'),
      summary: str('summary'),
      sourceUrl: str('sourceUrl'),
      isDone: json['isDone'] == true,
      dueAt: parseDate(str('dueAt')),
    );
  }
}
