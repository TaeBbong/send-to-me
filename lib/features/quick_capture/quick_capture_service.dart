import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges the native "quick capture" surfaces (iOS App Intent / Back Tap,
/// Android Quick Settings tile) to the Flutter app.
///
/// Quick captures are saved *natively* into a small shared queue while the main
/// app may be closed (iOS App Group `UserDefaults`, Android `SharedPreferences`).
/// On launch and on resume we [drainPending] that queue and turn each entry into
/// a memo via the normal `MemoActions.send` path, so captured text gets the same
/// instant-save + background classification as anything typed in the composer.
///
/// The native side owns the storage format; here we only ever pull-and-clear.
class QuickCaptureService {
  QuickCaptureService([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('app/quick_capture');

  final MethodChannel _channel;

  /// Returns every queued capture (oldest first) and clears the native queue in
  /// the same call, so a capture is never imported twice. Returns an empty list
  /// when there is nothing pending or the platform has no native surface.
  Future<List<String>> drainPending() async {
    final result = await _channel.invokeListMethod<String>('drainPending');
    if (result == null) return const [];
    return result.where((e) => e.trim().isNotEmpty).toList(growable: false);
  }
}

final quickCaptureServiceProvider = Provider<QuickCaptureService>(
  (ref) => QuickCaptureService(),
);
