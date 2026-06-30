import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Attempts to initialize Firebase, returning whether it succeeded.
///
/// The app is local-first: if Firebase isn't configured yet (no
/// `flutterfire configure` run), this returns `false` and the LLM features stay
/// disabled instead of crashing the app.
///
/// After running `flutterfire configure`, switch to the generated options for
/// reliable cross-platform init:
///
/// ```dart
/// import '../../firebase_options.dart';
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
Future<bool> tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // App Check guards Firebase AI Logic (Gemini) so only genuine installs can
    // spend the project's quota. Release uses the platform attestation
    // providers; debug uses the debug provider (register the printed token in
    // the Firebase console to test on emulators/simulators). DeviceCheck is
    // used on Apple rather than App Attest to keep iOS 13 support.
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? AndroidPlayIntegrityProvider()
          : AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? AppleDeviceCheckProvider()
          : AppleDebugProvider(),
    );
    return true;
  } catch (_) {
    return false;
  }
}
