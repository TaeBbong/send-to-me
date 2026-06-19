import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../domain/entities/memo.dart';
import '../../categories/category_providers.dart';
import '../memo_chat_providers.dart';

/// Long-press action sheet for a memo: move it to another category (manual
/// re-classification / emptying the draft bucket) or delete it.
Future<void> showMemoActionsSheet(BuildContext context, Memo memo) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _MemoActionsSheet(memo: memo),
  );
}

class _MemoActionsSheet extends ConsumerWidget {
  const _MemoActionsSheet({required this.memo});

  final Memo memo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final others = categories.where((c) => c.id != memo.categoryId).toList();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              '다른 카테고리로 이동',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (others.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Text('이동할 다른 카테고리가 없어요.'),
                  )
                else
                  for (final c in others)
                    ListTile(
                      leading: Text(
                        c.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(c.name),
                      subtitle: Text(c.kind.label),
                      onTap: () {
                        ref.read(memoActionsProvider).moveToCategory(memo, c.id);
                        Navigator.of(context).pop();
                      },
                    ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              '삭제',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              ref.read(memoActionsProvider).delete(memo.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
