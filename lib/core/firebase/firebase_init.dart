import 'package:firebase_core/firebase_core.dart';
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
    return true;
  } catch (_) {
    return false;
  }
}
