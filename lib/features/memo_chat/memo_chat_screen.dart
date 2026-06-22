import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/firebase/firebase_status.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/memo.dart';
import 'memo_chat_providers.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/date_divider.dart';
import 'widgets/memo_bubble.dart';

/// The home screen: a messenger-style "note to self" where memos pile up as
/// outgoing bubbles and a background LLM sorts them into category rooms.
class MemoChatScreen extends ConsumerStatefulWidget {
  const MemoChatScreen({super.key});

  @override
  ConsumerState<MemoChatScreen> createState() => _MemoChatScreenState();
}

class _MemoChatScreenState extends ConsumerState<MemoChatScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  int _lastCount = 0;

  /// Whether the list was at (or near) the bottom — tracked so the keyboard only
  /// pulls the latest memo up when the user wasn't reading older ones.
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    _atBottom = pos.pixels >= pos.maxScrollExtent - 80;
  }

  @override
  void didChangeMetrics() {
    // Keyboard opening changes the bottom inset. Only follow it to the bottom
    // when the user was already there — if they scrolled up to read an older
    // memo, leave their position alone.
    if (_atBottom) _scrollToBottomSoon();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final memosAsync = ref.watch(allMemosProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메모'),
        titleSpacing: AppSpacing.lg,
        bottom: firebaseReady
            ? null
            : const _FirebaseHintBanner(),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: memosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('메모를 불러오지 못했어요: $e')),
              data: (memos) {
                if (memos.isEmpty) {
                  return const EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: '아직 메모가 없어요',
                    message: '아래에 생각나는 걸 그냥 적어 보세요.\n저장하면 AI가 알아서 분류해 둘게요.',
                  );
                }
                if (memos.length != _lastCount) {
                  _lastCount = memos.length;
                  _scrollToBottomSoon();
                }
                final entries = _buildEntries(memos);
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return switch (entry) {
                      _DateEntry(:final label) => DateDivider(label),
                      _MemoEntry(:final memo) => MemoBubble(memo),
                    };
                  },
                );
              },
              ),
            ),
          ),
          ChatInputBar(
            hintText: AppConstants.appTagline,
            offerClipboard: true,
            onSend: (text) => ref.read(memoActionsProvider).send(text),
          ),
        ],
      ),
    );
  }

  /// Converts a newest-first memo list into an oldest-first list of chat
  /// entries with day separators inserted.
  List<_ChatEntry> _buildEntries(List<Memo> newestFirst) {
    final ordered = newestFirst.reversed.toList();
    final entries = <_ChatEntry>[];
    DateTime? lastDay;
    for (final memo in ordered) {
      if (lastDay == null ||
          DateFormatter.isDifferentDay(lastDay, memo.createdAt)) {
        entries.add(_DateEntry(DateFormatter.dateHeader(memo.createdAt)));
        lastDay = memo.createdAt;
      }
      entries.add(_MemoEntry(memo));
    }
    return entries;
  }
}

sealed class _ChatEntry {
  const _ChatEntry();
}

class _DateEntry extends _ChatEntry {
  const _DateEntry(this.label);
  final String label;
}

class _MemoEntry extends _ChatEntry {
  const _MemoEntry(this.memo);
  final Memo memo;
}

/// A thin app-bar banner shown when Firebase isn't configured yet.
class _FirebaseHintBanner extends StatelessWidget implements PreferredSizeWidget {
  const _FirebaseHintBanner();

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colors.errorContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        'Firebase 미설정 — 메모는 저장되지만 자동 분류는 꺼져 있어요',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onErrorContainer,
        ),
      ),
    );
  }
}
