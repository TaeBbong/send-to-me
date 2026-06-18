import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

/// Thin wrapper around [share_handler] that turns incoming share intents
/// (from other apps' "share" sheets) into plain memo text.
///
/// A memo is text-only ([Memo.content] + an optional detected `sourceUrl`),
/// so we surface the shared [SharedMedia.content] — which is the shared text
/// or URL — and ignore binary attachments for now (there is no image storage).
class SharedIntentService {
  SharedIntentService(this._handler);

  final ShareHandlerPlatform _handler;

  /// The share that cold-started the app, if any. Call once on launch.
  Future<SharedMedia?> getInitialSharedMedia() => _handler.getInitialSharedMedia();

  /// Clears the cached cold-start share so a hot restart doesn't replay it.
  Future<void> reset() => _handler.resetInitialSharedMedia();

  /// Shares received while the app is already running (warm).
  Stream<SharedMedia> get sharedMediaStream => _handler.sharedMediaStream;

  /// Extracts memo-ready text from a [SharedMedia]. Returns null when there is
  /// nothing we can turn into a text memo (e.g. an image-only share).
  static String? extractText(SharedMedia media) {
    final content = media.content?.trim();
    if (content != null && content.isNotEmpty) return content;
    return null;
  }
}

final sharedIntentServiceProvider = Provider<SharedIntentService>(
  (ref) => SharedIntentService(ShareHandlerPlatform.instance),
);
