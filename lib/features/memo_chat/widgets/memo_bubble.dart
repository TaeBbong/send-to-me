import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/url_detector.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/memo.dart';
import '../../categories/category_providers.dart';
import '../memo_chat_providers.dart';
import 'chat_bubble.dart';

/// Renders one memo as an outgoing bubble plus a status footer that reflects the
/// background classification lifecycle.
class MemoBubble extends ConsumerWidget {
  const MemoBubble(this.memo, {super.key});

  final Memo memo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChatBubble(
      outgoing: true,
      onLongPress: () => _confirmDelete(context, ref),
      footer: _Footer(memo),
      child: Text(UrlDetector.decodeInText(memo.content)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('이 메모를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(memoActionsProvider).delete(memo.id);
    }
  }
}

class _Footer extends ConsumerWidget {
  const _Footer(this.memo);

  final Memo memo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final time = Text(
      DateFormatter.time(memo.createdAt),
      style: context.textTheme.bodySmall?.copyWith(color: c.textSecondary),
    );

    final Widget status = switch (memo.status) {
      MemoStatus.pending || MemoStatus.processing => _StatusPill(
        icon: null,
        label: '분류 중',
        showSpinner: true,
      ),
      MemoStatus.failed => GestureDetector(
        onTap: () => ref.read(memoActionsProvider).retry(memo),
        child: const _StatusPill(
          icon: Icons.refresh_rounded,
          label: '분류 실패 · 재시도',
        ),
      ),
      MemoStatus.classified => _CategoryChip(memo: memo),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [status, const SizedBox(width: AppSpacing.sm), time],
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  const _CategoryChip({required this.memo});

  final Memo memo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = memo.categoryId;
    if (id == null) return const SizedBox.shrink();
    final category = ref.watch(categoryByIdProvider(id));
    if (category == null) return const SizedBox.shrink();

    final color = context.appColors.categoryColor(category.id);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.roomPath(category.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: context.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    this.icon,
    this.showSpinner = false,
  });

  final String label;
  final IconData? icon;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.systemBubble,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation(c.onSystemBubble),
              ),
            ),
          if (icon != null) Icon(icon, size: 12, color: c.onSystemBubble),
          if (showSpinner || icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(color: c.onSystemBubble),
          ),
        ],
      ),
    );
  }
}
