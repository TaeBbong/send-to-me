import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/app_providers.dart';
import '../../core/utils/link_metadata.dart';
import '../../core/utils/url_detector.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';
import '../classification/classification_providers.dart';

const _uuid = Uuid();

/// Reactive stream of every memo, newest first — backs the note-to-self chat.
final allMemosProvider = StreamProvider<List<Memo>>(
  (ref) => ref.watch(memoRepositoryProvider).watchAll(),
);

/// Memos not yet assigned to a category (used for the "분류 중" affordance).
final unclassifiedMemosProvider = StreamProvider<List<Memo>>(
  (ref) => ref.watch(memoRepositoryProvider).watchUnclassified(),
);

final memoActionsProvider = Provider<MemoActions>(MemoActions.new);

/// Imperative memo operations invoked from the UI.
class MemoActions {
  MemoActions(this._ref);
  final Ref _ref;

  /// Saves a memo immediately (requirement #2: instant 1st save) and kicks off
  /// background classification without blocking the UI.
  Future<void> send(String rawContent) async {
    final content = rawContent.trim();
    if (content.isEmpty) return;

    final memo = Memo(
      id: _uuid.v4(),
      content: content,
      status: MemoStatus.pending,
      createdAt: DateTime.now(),
      sourceUrl: UrlDetector.firstUrl(content),
    );

    await _ref.read(memoRepositoryProvider).add(memo);
    // Fire-and-forget: classification happens in the background.
    unawaited(_ref.read(classificationWorkerProvider).processPending());
  }

  /// Adds a memo directly into a specific category (e.g. typed inside a room),
  /// bypassing classification — it already has a home.
  Future<void> sendToCategory(String rawContent, String categoryId) async {
    final content = rawContent.trim();
    if (content.isEmpty) return;

    final now = DateTime.now();
    final sourceUrl = UrlDetector.firstUrl(content);
    final memo = Memo(
      id: _uuid.v4(),
      content: content,
      status: MemoStatus.classified,
      createdAt: now,
      categoryId: categoryId,
      classifiedAt: now,
      sourceUrl: sourceUrl,
    );
    await _ref.read(memoRepositoryProvider).add(memo);

    // Direct-to-room memos skip classification, so fetch the link title here.
    if (sourceUrl != null) {
      unawaited(_fetchLinkTitle(memo.id, sourceUrl));
    }
  }

  Future<void> _fetchLinkTitle(String memoId, String url) async {
    final title = await _ref.read(linkMetadataServiceProvider).fetchTitle(url);
    if (title != null && title.isNotEmpty) {
      await _ref.read(memoRepositoryProvider).updateLinkTitle(memoId, title);
    }
  }

  Future<void> retry(Memo memo) async {
    await _ref
        .read(memoRepositoryProvider)
        .update(memo.copyWith(status: MemoStatus.pending));
    unawaited(_ref.read(classificationWorkerProvider).processPending());
  }

  Future<void> delete(String id) =>
      _ref.read(memoRepositoryProvider).delete(id);

  Future<void> setDone(String id, bool isDone) =>
      _ref.read(memoRepositoryProvider).setDone(id, isDone);

  /// Manually re-files a memo into [categoryId] (fixing a misclassification or
  /// emptying the draft bucket). Bumps the target category to the top.
  Future<void> moveToCategory(Memo memo, String categoryId) async {
    if (memo.categoryId == categoryId) return;
    final now = DateTime.now();
    await _ref.read(memoRepositoryProvider).update(
      memo.copyWith(
        categoryId: categoryId,
        status: MemoStatus.classified,
        classifiedAt: memo.classifiedAt ?? now,
      ),
    );
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final category = (await categoryRepo.getById(categoryId)).valueOrNull;
    if (category != null) {
      await categoryRepo.update(category.copyWith(updatedAt: now));
    }
  }
}
