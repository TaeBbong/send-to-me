import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/result.dart';
import '../../core/firebase/firebase_status.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/link_metadata.dart';
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

  /// Serializes the (fast) category create/dedup section so that memos being
  /// classified in parallel never create duplicate categories.
  Future<void> _categoryGate = Future<void>.value();

  /// Drains every pending memo, classifying up to
  /// [AppConstants.classifyConcurrency] at a time. Safe to call repeatedly;
  /// overlapping runs are coalesced, and memos added mid-run are picked up by
  /// the drain loop.
  Future<void> processPending() async {
    if (_running) return;
    if (!_ref.read(firebaseReadyProvider)) return;
    if (!_ref.read(settingsControllerProvider).autoClassify) return;

    _running = true;
    try {
      final repo = _ref.read(memoRepositoryProvider);
      while (true) {
        final pending = (await repo.getPending()).valueOrNull ?? const <Memo>[];
        if (pending.isEmpty) break;
        await _processConcurrently(pending);
      }
    } finally {
      _running = false;
    }
  }

  /// Runs [_process] over [memos] with a bounded number of concurrent workers.
  Future<void> _processConcurrently(List<Memo> memos) async {
    final queue = [...memos];
    final workerCount = AppConstants.classifyConcurrency.clamp(1, memos.length);

    Future<void> drain() async {
      while (queue.isNotEmpty) {
        await _process(queue.removeAt(0));
      }
    }

    await Future.wait([for (var i = 0; i < workerCount; i++) drain()]);
  }

  Future<void> _process(Memo memo) async {
    final memoRepo = _ref.read(memoRepositoryProvider);
    try {
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
          // Timed out or errored → file it in the draft bucket, no retry.
          await _assignToDraft(memo);
      }
    } catch (_) {
      // Never leave a memo stuck in `processing` — that would loop forever.
      try {
        await _assignToDraft(memo);
      } catch (_) {
        await memoRepo.update(memo.copyWith(status: MemoStatus.failed));
      }
    }
  }

  /// Files [memo] into the fallback "draft" category (created on demand) and
  /// marks it classified, so a failed/timed-out memo still lands somewhere.
  Future<void> _assignToDraft(Memo memo) async {
    final memoRepo = _ref.read(memoRepositoryProvider);
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    final categoryId = await _ensureDraftCategory(now);
    await memoRepo.update(
      memo.copyWith(
        status: MemoStatus.classified,
        categoryId: categoryId,
        classifiedAt: now,
      ),
    );

    final cat = (await categoryRepo.getById(categoryId)).valueOrNull;
    if (cat != null) {
      await categoryRepo.update(cat.copyWith(updatedAt: now));
    }
  }

  /// Returns the draft category id, creating the singleton category if missing.
  Future<String> _ensureDraftCategory(DateTime now) {
    return _serializeCategory(() async {
      final categoryRepo = _ref.read(categoryRepositoryProvider);
      final existing =
          (await categoryRepo.getById(AppConstants.draftCategoryId)).valueOrNull;
      if (existing != null) return existing.id;

      final category = Category(
        id: AppConstants.draftCategoryId,
        name: AppConstants.draftCategoryName,
        emoji: AppConstants.draftCategoryEmoji,
        kind: CategoryKind.note,
        description: '분류에 실패했거나 시간이 초과된 메모가 모이는 임시 보관함',
        createdAt: now,
        updatedAt: now,
      );
      await categoryRepo.add(category);
      return category.id;
    });
  }

  /// Runs [action] after any in-flight category creation completes, so creates
  /// happen one at a time (each sees the previous one's result).
  Future<T> _serializeCategory<T>(Future<T> Function() action) {
    final previous = _categoryGate;
    final completer = Completer<void>();
    _categoryGate = completer.future;
    return previous.then((_) => action()).whenComplete(completer.complete);
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

    final sourceUrl = result.sourceUrl ?? UrlDetector.firstUrl(memo.content);

    await memoRepo.update(
      memo.copyWith(
        status: MemoStatus.classified,
        categoryId: categoryId,
        summary: result.summary,
        sourceUrl: sourceUrl,
        isDone: result.isDone,
        dueAt: result.dueAt,
        classifiedAt: now,
      ),
    );

    // Best-effort, non-blocking: fetch the page title so reference cards show
    // what the link is. Fetch the URL exactly as the user typed it — the
    // model's echoed sourceUrl may be re-encoded/trimmed and 404 — and let the
    // room update reactively when the title arrives.
    final fetchUrl = UrlDetector.firstUrl(memo.content) ?? sourceUrl;
    if (fetchUrl != null && memo.linkTitle == null) {
      unawaited(_fetchLinkTitle(memo.id, fetchUrl));
    }

    // Bump the category so its "room" floats to the top of the list.
    final cat = (await categoryRepo.getById(categoryId)).valueOrNull;
    if (cat != null) {
      await categoryRepo.update(cat.copyWith(updatedAt: now));
    }
  }

  /// Fetches and stores the link title for a classified memo, ignoring errors.
  Future<void> _fetchLinkTitle(String memoId, String url) async {
    final title = await _ref.read(linkMetadataServiceProvider).fetchTitle(url);
    if (title != null && title.isNotEmpty) {
      await _ref.read(memoRepositoryProvider).updateLinkTitle(memoId, title);
    }
  }

  /// Returns the id of the category the memo should land in, creating a new
  /// category when appropriate. The create/dedup path is serialized so parallel
  /// classification can't spawn duplicate categories.
  Future<String> _resolveCategory({
    required Memo memo,
    required ClassificationResult result,
    required List<Category> categories,
    required bool allowCreate,
    required DateTime now,
  }) async {
    final matchedId = result.matchedCategoryId;
    if (matchedId != null && categories.any((c) => c.id == matchedId)) {
      return matchedId;
    }

    return _serializeCategory(() async {
      final categoryRepo = _ref.read(categoryRepositoryProvider);
      // Re-read fresh: a sibling memo may have just created the category.
      final fresh = (await categoryRepo.getAll()).valueOrNull ?? categories;

      if (matchedId != null && fresh.any((c) => c.id == matchedId)) {
        return matchedId;
      }

      // With auto-create off, drop into the most recent existing room (but still
      // bootstrap the very first category — a memo must live somewhere).
      if (!allowCreate && fresh.isNotEmpty) return fresh.first.id;

      final kind = result.newCategoryKind ?? CategoryKind.note;
      final name = result.newCategoryName ?? kind.label;

      // Reuse an existing same-named category instead of duplicating it.
      final normalized = name.trim().toLowerCase();
      for (final c in fresh) {
        if (c.name.trim().toLowerCase() == normalized) return c.id;
      }

      final category = Category(
        id: _uuid.v4(),
        name: name,
        emoji: result.newCategoryEmoji ?? kind.defaultEmoji,
        kind: kind,
        description: result.newCategoryDescription ?? memo.content,
        createdAt: now,
        updatedAt: now,
      );
      await categoryRepo.add(category);
      return category.id;
    });
  }
}
