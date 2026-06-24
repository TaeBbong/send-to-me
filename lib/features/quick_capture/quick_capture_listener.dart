import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../memo_chat/memo_chat_providers.dart';
import 'quick_capture_service.dart';

/// Drains the native quick-capture queue into real memos.
///
/// A quick capture (iOS Back Tap / App Intent, Android Quick Settings tile) is
/// stashed natively while the app may be closed. We pull it in two moments:
///   * on launch — captures made while the app was dead, and
///   * on every resume — captures made while the app was backgrounded.
///
/// Each entry goes through [MemoActions.send], so it saves instantly as
/// `pending` and kicks off background classification, exactly like the composer
/// and the share-sheet path ([ShareIntentListener]).
///
/// Mounted high in the tree (around [MaterialApp.router]) so it runs regardless
/// of which screen is showing.
class QuickCaptureListener extends ConsumerStatefulWidget {
  const QuickCaptureListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<QuickCaptureListener> createState() =>
      _QuickCaptureListenerState();
}

class _QuickCaptureListenerState extends ConsumerState<QuickCaptureListener>
    with WidgetsBindingObserver {
  bool _draining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _drain();
  }

  Future<void> _drain() async {
    // Guard against the launch drain and the first resume drain overlapping.
    if (_draining) return;
    _draining = true;
    try {
      final captures = await ref.read(quickCaptureServiceProvider).drainPending();
      if (captures.isEmpty) return;
      final actions = ref.read(memoActionsProvider);
      for (final text in captures) {
        await actions.send(text);
      }
    } finally {
      _draining = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
