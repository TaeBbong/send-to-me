/// Domain-level failures, decoupled from any specific package's exceptions.
///
/// Repositories and services translate raw exceptions (Drift, firebase_ai,
/// network) into one of these so the presentation layer can react uniformly.
sealed class Failure {
  const Failure(this.message, {this.cause});

  /// Human-readable, user-safe message (Korean copy lives at the UI layer;
  /// this is a developer/diagnostic message).
  final String message;

  /// The underlying error, if any (for logging).
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// Local database / persistence failure.
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

/// LLM / Firebase AI call failed (network, quota, parse, etc.).
class LlmFailure extends Failure {
  const LlmFailure(super.message, {super.cause});
}

/// Firebase not initialized / not configured by the developer yet.
class NotConfiguredFailure extends Failure {
  const NotConfiguredFailure(super.message, {super.cause});
}

/// Anything we did not specifically anticipate.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
