import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../domain/entities/memo.dart';
import '../../categories/category_providers.dart';
import '../memo_chat_providers.dart';

/// Long-press action sheet for a memo: share it to another app, move it to
/// another category (manual re-classification / emptying the draft bucket), or
/// delete it.
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
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: const Text('공유'),
            onTap: () => _share(context),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
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

  /// Opens the OS share sheet with the memo's text. For a link memo with a
  /// resolved title we share "title + link" so the recipient gets context.
  Future<void> _share(BuildContext context) async {
    final title = memo.linkTitle;
    final text = (title != null && title.isNotEmpty)
        ? '$title\n${memo.content}'
        : memo.content;

    // Anchor the iPad share popover to the tapped row before we pop the sheet.
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null && box.hasSize)
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    Navigator.of(context).pop();
    await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  }
}
