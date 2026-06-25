import 'package:flutter/foundation.dart';

/// Build environments. We keep this to a single compile-time switch instead of
/// full build flavors — flavors mean separate applicationIds, iOS schemes and
/// signing, which we don't need just to seed dev data and replay onboarding.
enum AppEnv { dev, prod }

/// The active [AppEnv], resolved once at startup.
///
/// Resolution order:
///  1. an explicit `--dart-define=APP_ENV=dev|prod` (lets you build a dev-mode
///     release APK for on-device testing), else
///  2. the build mode — `dev` in debug/profile, `prod` in release.
abstract final class Env {
  static const String _override = String.fromEnvironment('APP_ENV');

  static final AppEnv current = switch (_override) {
    'dev' => AppEnv.dev,
    'prod' => AppEnv.prod,
    _ => kReleaseMode ? AppEnv.prod : AppEnv.dev,
  };

  static bool get isDev => current == AppEnv.dev;
  static bool get isProd => current == AppEnv.prod;
}
