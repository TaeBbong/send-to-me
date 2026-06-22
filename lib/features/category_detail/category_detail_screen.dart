import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/category.dart';
import '../categories/category_providers.dart';
import '../classification/classification_providers.dart';
import '../classification/reclassify_status.dart';
import '../memo_chat/memo_chat_providers.dart';
import '../memo_chat/widgets/chat_input_bar.dart';
import 'widgets/kind_layouts.dart';

/// A single category "chat room". Its body is rendered by a deterministic
/// per-kind template ([KindMemoLayout]) chosen from the category's kind — the
/// kind itself is picked once by the classifier — and you can keep tossing
/// memos straight into the room.
class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(categoryId));
    final memosAsync = ref.watch(memosByCategoryProvider(categoryId));
    final isDraft = category?.id == AppConstants.draftCategoryId;
    final reclassify = ref.watch(reclassifyStatusProvider);

    // Announce the result when a re-classify run finishes.
    ref.listen(reclassifyStatusProvider, (prev, next) {
      if (!isDraft || !context.mounted) return;
      if (prev != null && prev.running && !next.running) {
        final message = next.moved > 0
            ? '${next.moved}개를 다른 카테고리로 옮겼어요.'
            : '옮길 만한 카테고리를 찾지 못했어요.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: '카테고리를 찾을 수 없어요',
          message: '삭제되었거나 보관된 카테고리일 수 있어요.',
        ),
      );
    }

    final accent = context.appColors.categoryColor(category.id);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _RoomTitle(category: category, accent: accent),
        actions: [
          if (isDraft)
            if (reclassify.running)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                tooltip: '전체 재분류',
                icon: const Icon(Icons.auto_awesome_rounded),
                onPressed: () =>
                    ref.read(classificationWorkerProvider).reclassifyDrafts(),
              ),
        ],
      ),
      body: Column(
        children: [
          if (isDraft && reclassify.running)
            _ReclassifyBanner(status: reclassify, accent: accent),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: memosAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('메모를 불러오지 못했어요: $e')),
                data: (memos) {
                  if (memos.isEmpty) {
                    return const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: '이 방은 아직 비어 있어요',
                      message: '아래에 적으면 이 카테고리로 바로 저장돼요.',
                    );
                  }
                  return KindMemoLayout(
                    kind: category.kind,
                    memos: memos,
                    accent: accent,
                  );
                },
              ),
            ),
          ),
          ChatInputBar(
            hintText: '${category.name}에 추가…',
            onSend: (text) => ref
                .read(memoActionsProvider)
                .sendToCategory(text, category.id),
          ),
        ],
      ),
    );
  }
}

class _RoomTitle extends StatelessWidget {
  const _RoomTitle({required this.category, required this.accent});

  final Category category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(category.emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium,
              ),
              Text(
                category.kind.label,
                style: context.textTheme.labelSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A thin progress strip shown while draft memos are being re-classified.
class _ReclassifyBanner extends StatelessWidget {
  const _ReclassifyBanner({required this.status, required this.accent});

  final ReclassifyStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final moved = status.moved > 0 ? ' · ${status.moved}개 이동' : '';
    return Container(
      width: double.infinity,
      color: accent.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '재분류 중… ${status.done}/${status.total}$moved',
              style: context.textTheme.labelMedium?.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
