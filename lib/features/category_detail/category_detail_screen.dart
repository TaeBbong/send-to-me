import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/category.dart';
import '../categories/category_providers.dart';
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
      ),
      body: Column(
        children: [
          Expanded(
            child: memosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
