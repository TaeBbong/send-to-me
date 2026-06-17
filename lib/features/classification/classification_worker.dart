import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/result.dart';
import '../../core/firebase/firebase_status.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/url_detector.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/classification_result.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';
import '../settings/settings_controller.dart';
import 'classification_providers.dart';

const _uuid = Uuid();

/// Drains pending memos through [ClassificationService] in the background and
/// persists the resulting category assignment.
///
/// This is the heart of requirement #2/#3: a memo is saved instantly, then
/// asynchronously matched to an existing category — or a brand-new one is
/// created when nothing fits.
class ClassificationWorker {
  ClassificationWorker(this._ref);

  final Ref _ref;
  bool _running = false;

  /// Process every memo currently in the pending/processing state. Safe to call
  /// repeatedly; concurrent runs are coalesced.
  Future<void> processPending() async {
    if (_running) return;
    if (!_ref.read(firebaseReadyProvider)) return;
    if (!_ref.read(settingsControllerProvider).autoClassify) return;

    _running = true;
    try {
      final pending =
          (await _ref.read(memoRepositoryProvider).getPending()).valueOrNull ??
          const [];
      for (final memo in pending) {
        await _process(memo);
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _process(Memo memo) async {
    final memoRepo = _ref.read(memoRepositoryProvider);
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final service = _ref.read(classificationServiceProvider);
    final settings = _ref.read(settingsControllerProvider);

    await memoRepo.update(memo.copyWith(status: MemoStatus.processing));

    final categories =
        (await categoryRepo.getAll()).valueOrNull ?? const <Category>[];

    final result = await service.classify(
      content: memo.content,
      existing: categories,
      modelName: settings.geminiModel,
      allowNewCategory: settings.autoCreateCategory,
      generateSummary: settings.generateSummaries,
    );

    switch (result) {
      case Ok(value: final classification):
        await _apply(memo, classification, categories);
      case Err():
        await memoRepo.update(memo.copyWith(status: MemoStatus.failed));
    }
  }

  Future<void> _apply(
    Memo memo,
    ClassificationResult result,
    List<Category> categories,
  ) async {
    final memoRepo = _ref.read(memoRepositoryProvider);
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final settings = _ref.read(settingsControllerProvider);
    final now = DateTime.now();

    final categoryId = await _resolveCategory(
      memo: memo,
      result: result,
      categories: categories,
      allowCreate: settings.autoCreateCategory,
      now: now,
    );

    await memoRepo.update(
      memo.copyWith(
        status: MemoStatus.classified,
        categoryId: categoryId,
        summary: result.summary,
        sourceUrl: result.sourceUrl ?? UrlDetector.firstUrl(memo.content),
        isDone: result.isDone,
        dueAt: result.dueAt,
        classifiedAt: now,
      ),
    );

    // Bump the category so its "room" floats to the top of the list.
    final cat = (await categoryRepo.getById(categoryId)).valueOrNull;
    if (cat != null) {
      await categoryRepo.update(cat.copyWith(updatedAt: now));
    }
  }

  /// Returns the id of the category the memo should land in, creating a new
  /// category when appropriate.
  Future<String> _resolveCategory({
    required Memo memo,
    required ClassificationResult result,
    required List<Category> categories,
    required bool allowCreate,
    required DateTime now,
  }) async {
    final matchedId = result.matchedCategoryId;
    final hasValidMatch =
        matchedId != null && categories.any((c) => c.id == matchedId);
    if (hasValidMatch) return matchedId;

    // New category needed. We always bootstrap the first category even when
    // auto-create is off (a memo must live somewhere); otherwise, with the
    // toggle off, fall back to the most recently used existing room.
    if (!allowCreate && categories.isNotEmpty) {
      return categories.first.id;
    }

    final kind = result.newCategoryKind ?? CategoryKind.note;
    final category = Category(
      id: _uuid.v4(),
      name: result.newCategoryName ?? kind.label,
      emoji: result.newCategoryEmoji ?? kind.defaultEmoji,
      kind: kind,
      description: result.newCategoryDescription ?? memo.content,
      createdAt: now,
      updatedAt: now,
    );
    await _ref.read(categoryRepositoryProvider).add(category);
    return category.id;
  }
}
