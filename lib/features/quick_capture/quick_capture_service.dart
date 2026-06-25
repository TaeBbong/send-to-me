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

  /// Whether the Android accessibility-shortcut service is currently enabled.
  /// Android-only; returns false elsewhere (and if the channel is unavailable).
  Future<bool> isAccessibilityEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system Accessibility settings (deep-linked to our service on
  /// Android 11+) so the user can enable the shortcut. No-op where unsupported.
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } on MissingPluginException {
      // No native surface on this platform — nothing to open.
    }
  }
}

final quickCaptureServiceProvider = Provider<QuickCaptureService>(
  (ref) => QuickCaptureService(),
);
