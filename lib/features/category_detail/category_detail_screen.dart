import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_status.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/memo.dart';
import '../categories/category_providers.dart';
import '../memo_chat/memo_chat_providers.dart';
import '../memo_chat/widgets/chat_input_bar.dart';
import '../settings/settings_controller.dart';
import 'genui/genui_cache_repository.dart';
import 'genui/genui_room_view.dart';
import 'widgets/kind_layouts.dart';

/// A single category "chat room". Its body is rendered by generative UI
/// (requirement #5) with a deterministic per-kind fallback, and you can keep
/// tossing memos straight into the room.
class CategoryDetailScreen extends ConsumerStatefulWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  bool? _aiMode; // null until we know whether Firebase is ready
  int _regenToken = 0;

  /// Drops the cached AI render and rebuilds the room view, forcing one fresh
  /// generation. Wired to the app-bar refresh and the "stale" hint.
  Future<void> _regenerate(String categoryId) async {
    await ref.read(genUiCacheRepositoryProvider).clear(categoryId);
    if (mounted) setState(() => _regenToken++);
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryByIdProvider(widget.categoryId));
    final memosAsync = ref.watch(memosByCategoryProvider(widget.categoryId));
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final modelName = ref.watch(
      settingsControllerProvider.select((s) => s.geminiModel),
    );

    final aiMode = _aiMode ?? firebaseReady;

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
          if (firebaseReady)
            IconButton(
              tooltip: aiMode ? '기본 보기' : 'AI 화면',
              icon: Icon(
                aiMode ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                color: aiMode ? accent : null,
              ),
              onPressed: () => setState(() => _aiMode = !aiMode),
            ),
          if (aiMode && firebaseReady)
            IconButton(
              tooltip: '다시 생성',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _regenerate(category.id),
            ),
        ],
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
                return _RoomBody(
                  aiMode: aiMode,
                  category: category,
                  memos: memos,
                  modelName: modelName,
                  accent: accent,
                  regenToken: _regenToken,
                  onRegenerate: () => _regenerate(category.id),
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

class _RoomBody extends StatelessWidget {
  const _RoomBody({
    required this.aiMode,
    required this.category,
    required this.memos,
    required this.modelName,
    required this.accent,
    required this.regenToken,
    required this.onRegenerate,
  });

  final bool aiMode;
  final Category category;
  final List<Memo> memos;
  final String modelName;
  final Color accent;
  final int regenToken;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    if (!aiMode) {
      return KindMemoLayout(kind: category.kind, memos: memos, accent: accent);
    }
    // The view caches its generated UI; it only recreates on manual regenerate
    // (regenToken), not when memos change — a "다시 생성" hint handles staleness.
    return GenUiRoomView(
      key: ValueKey('${category.id}-$regenToken'),
      category: category,
      memos: memos,
      modelName: modelName,
      accent: accent,
      onRegenerate: onRegenerate,
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
