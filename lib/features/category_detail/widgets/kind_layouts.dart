import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/memo.dart';
import '../../memo_chat/memo_chat_providers.dart';

/// Deterministic, per-[CategoryKind] rendering of a room's memos.
///
/// This is the reliable backbone of requirement #5 ("different UI per category
/// type"): a checklist for todos, summarized cards for references, a timeline
/// for ideas, plain bubbles otherwise. The generative-UI layer renders on top
/// of this when Firebase is configured, and falls back to it otherwise.
class KindMemoLayout extends StatelessWidget {
  const KindMemoLayout({
    super.key,
    required this.kind,
    required this.memos,
    required this.accent,
  });

  final CategoryKind kind;
  final List<Memo> memos;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      CategoryKind.todo => _TodoLayout(memos: memos, accent: accent),
      CategoryKind.reference => _ReferenceLayout(memos: memos, accent: accent),
      CategoryKind.idea => _TimelineLayout(memos: memos, accent: accent),
      CategoryKind.note => _NoteLayout(memos: memos),
    };
  }
}

// ---------------------------------------------------------------- todo --------
class _TodoLayout extends ConsumerWidget {
  const _TodoLayout({required this.memos, required this.accent});

  final List<Memo> memos;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...memos]
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.createdAt.compareTo(b.createdAt);
      });
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final memo = sorted[index];
        return Card(
          child: CheckboxListTile(
            value: memo.isDone,
            activeColor: accent,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) =>
                ref.read(memoActionsProvider).setDone(memo.id, v ?? false),
            title: Text(
              memo.content,
              style: context.textTheme.bodyLarge?.copyWith(
                decoration: memo.isDone ? TextDecoration.lineThrough : null,
                color: memo.isDone ? context.appColors.textSecondary : null,
              ),
            ),
            subtitle: memo.dueAt != null
                ? Text('마감 ${DateFormatter.relative(memo.dueAt!)}')
                : null,
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------- reference --------
class _ReferenceLayout extends StatelessWidget {
  const _ReferenceLayout({required this.memos, required this.accent});

  final List<Memo> memos;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ordered = [...memos]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: ordered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final memo = ordered[index];
        final url = memo.sourceUrl;
        final title = url != null ? Uri.tryParse(url)?.host ?? url : memo.content;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bookmark_rounded, size: 16, color: accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                if (memo.summary != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(memo.summary!, style: context.textTheme.bodyMedium),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    memo.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
                if (url != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _open(url),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('열기'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ------------------------------------------------------------ timeline --------
class _TimelineLayout extends StatelessWidget {
  const _TimelineLayout({required this.memos, required this.accent});

  final List<Memo> memos;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ordered = [...memos]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final memo = ordered[index];
        final isLast = index == ordered.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: context.appColors.divider,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.relative(memo.createdAt),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            memo.content,
                            style: context.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- note --------
class _NoteLayout extends StatelessWidget {
  const _NoteLayout({required this.memos});

  final List<Memo> memos;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: memos.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final memo = memos[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memo.content, style: context.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormatter.relative(memo.createdAt),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
