import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/url_detector.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/memo.dart';
import '../../memo_chat/memo_chat_providers.dart';
import '../../memo_chat/widgets/memo_actions_sheet.dart';

/// Deterministic, per-[CategoryKind] rendering of a room's memos.
///
/// This is the single source of truth for "different UI per category type":
/// a checklist for todos, summarized cards for references, a timeline for
/// ideas, plain bubbles otherwise. The kind is chosen once by the classifier,
/// so the right template is picked the moment a category is created.
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

/// Wraps a memo tile so a long-press opens the move-to-category / delete sheet.
Widget _withMemoActions(BuildContext context, Memo memo, Widget child) {
  return GestureDetector(
    onLongPress: () => showMemoActionsSheet(context, memo),
    child: child,
  );
}

// ---------------------------------------------------------------- todo --------
/// Checklist with completed items grouped on top and pending ones below,
/// separated by a divider; each group is oldest-first. Toggling an item
/// re-sorts the list on the next build.
class _TodoLayout extends StatelessWidget {
  const _TodoLayout({required this.memos, required this.accent});

  final List<Memo> memos;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    int byAge(Memo a, Memo b) => a.createdAt.compareTo(b.createdAt);
    final done = memos.where((m) => m.isDone).toList()..sort(byAge);
    final pending = memos.where((m) => !m.isDone).toList()..sort(byAge);

    Widget tile(Memo m) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: _TodoTile(key: ValueKey(m.id), memo: m, accent: accent),
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final m in done) tile(m),
        if (done.isNotEmpty && pending.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1, color: context.appColors.divider),
          ),
        for (final m in pending) tile(m),
      ],
    );
  }
}

class _TodoTile extends ConsumerWidget {
  const _TodoTile({super.key, required this.memo, required this.accent});

  final Memo memo;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _withMemoActions(
      context,
      memo,
      Card(
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
          subtitle: _TodoMeta(memo: memo),
        ),
      ),
    );
  }
}

/// Timestamps under a TODO item: when it was registered and, once checked,
/// when it was completed — plus an optional due date.
class _TodoMeta extends StatelessWidget {
  const _TodoMeta({required this.memo});

  final Memo memo;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final muted = context.textTheme.labelSmall?.copyWith(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Text('등록 ${DateFormatter.stamp(memo.createdAt)}', style: muted),
        if (memo.isDone && memo.doneAt != null)
          Text(
            '완료 ${DateFormatter.stamp(memo.doneAt!)}',
            style: context.textTheme.labelSmall?.copyWith(color: accentDone),
          ),
        if (memo.dueAt != null)
          Text('마감 ${DateFormatter.relative(memo.dueAt!)}', style: muted),
      ],
    );
  }

  // A subtle "done" tint that reads as positive without importing the accent.
  static const Color accentDone = Color(0xFF2E7D32);
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
        final host = url != null ? Uri.tryParse(url)?.host : null;
        // Title: the fetched page title, else the clean domain. Subtitle always
        // carries the full decoded link below it.
        final title = memo.linkTitle ?? host ?? url ?? memo.content;
        final subtitleUrl = url == null ? null : UrlDetector.pretty(url);
        return _withMemoActions(
          context,
          memo,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.bookmark_rounded, size: 16, color: accent),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                if (subtitleUrl != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      subtitleUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (memo.summary != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(memo.summary!, style: context.textTheme.bodyMedium),
                ] else if (url == null) ...[
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
        ));
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
                      _withMemoActions(
                        context,
                        memo,
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              memo.content,
                              style: context.textTheme.bodyLarge,
                            ),
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
        return _withMemoActions(
          context,
          memo,
          Card(
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
          ),
        );
      },
    );
  }
}
