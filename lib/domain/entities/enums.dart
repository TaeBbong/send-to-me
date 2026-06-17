/// The "personality" of a category. The classifier picks one when creating a
/// new category, and the generative-UI layer uses it as a strong hint for how
/// to lay out the room (checklist / reference list / timeline / plain).
///
/// Note: with real generative UI the final layout is decided by the model at
/// runtime; [CategoryKind] only seeds the prompt and the room-list iconography.
enum CategoryKind {
  todo,
  reference,
  idea,
  note;

  /// A default emoji used when the model doesn't supply one.
  String get defaultEmoji => switch (this) {
    CategoryKind.todo => '✅',
    CategoryKind.reference => '🔖',
    CategoryKind.idea => '💡',
    CategoryKind.note => '📝',
  };

  /// Korean label shown in the room list and badges.
  String get label => switch (this) {
    CategoryKind.todo => '할 일',
    CategoryKind.reference => '참고자료',
    CategoryKind.idea => '아이디어',
    CategoryKind.note => '메모',
  };

  /// Short English tag (e.g. for badges: TODO / REF / IDEA / NOTE).
  String get tag => switch (this) {
    CategoryKind.todo => 'TODO',
    CategoryKind.reference => 'REF',
    CategoryKind.idea => 'IDEA',
    CategoryKind.note => 'NOTE',
  };

  static CategoryKind fromName(String? name) {
    return CategoryKind.values.firstWhere(
      (k) => k.name == name,
      orElse: () => CategoryKind.note,
    );
  }
}

/// Lifecycle of a memo with respect to background LLM classification.
enum MemoStatus {
  /// Saved locally, waiting to be picked up by the classification worker.
  pending,

  /// Currently being classified by the LLM.
  processing,

  /// Successfully assigned to a category.
  classified,

  /// Classification failed; memo stays visible and can be retried.
  failed;

  static MemoStatus fromName(String? name) {
    return MemoStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => MemoStatus.pending,
    );
  }
}
