import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

import '../../app/app_router.dart';
import '../../core/router/app_routes.dart';
import '../memo_chat/memo_chat_providers.dart';
import 'shared_intent_service.dart';

/// Listens for content shared into the app from other apps and turns it into a
/// memo immediately — no manual send needed. Saving a memo also kicks off the
/// background LLM classification, so "share" alone runs the whole pipeline.
///
/// Mounted high in the tree (around [MaterialApp.router]) so it works no matter
/// which screen is showing.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<SharedMedia>? _subscription;

  @override
  void initState() {
    super.initState();
    final service = ref.read(sharedIntentServiceProvider);

    // Warm shares: app already running when the user shares.
    _subscription = service.sharedMediaStream.listen(_handle);

    // Cold start: a share that launched the app. Handle after the first frame
    // so the router is ready to navigate.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final media = await service.getInitialSharedMedia();
      if (media != null) {
        _handle(media);
        // Avoid replaying the same share on hot restart.
        await service.reset();
      }
    });
  }

  void _handle(SharedMedia media) {
    final text = SharedIntentService.extractText(media);
    if (text == null) return;

    // Instant save + fire-and-forget classification (same path as the composer).
    ref.read(memoActionsProvider).send(text);
    // Land the user on the chat so they can watch it get sorted.
    ref.read(routerProvider).go(AppRoutes.chat);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
