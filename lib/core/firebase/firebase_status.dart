import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether `Firebase.initializeApp` succeeded at startup.
///
/// Overridden in `main()` after attempting initialization. When `false`, the
/// LLM features degrade gracefully (memos still save locally; classification is
/// skipped and the UI shows a "Firebase 미설정" hint) instead of crashing.
final firebaseReadyProvider = Provider<bool>(
  (ref) => throw UnimplementedError(
    'firebaseReadyProvider must be overridden in main()',
  ),
);
