/// App-wide constant values and identifiers.
abstract final class AppConstants {
  static const String appName = 'Awesome Memo';
  static const String appTagline = '생각나면 톡, 정리는 AI가.';

  /// Default Gemini model and its fallback, used by the classification and
  /// generative-UI services. Both are overridable from Settings.
  ///
  /// `gemini-3.5-flash` is the current no-cost-tier flash model on Firebase
  /// AI Logic; `gemini-2.5-flash` is the safe fallback if the primary is not
  /// available for a given project/region.
  static const String defaultModel = 'gemini-3.5-flash';
  static const String fallbackModel = 'gemini-2.5-flash';

  /// Selectable models surfaced in Settings. `gemini-2.5-flash-lite` is the
  /// fastest/cheapest option — a good fit for the lightweight classification
  /// task if `flash` feels slow.
  static const List<String> selectableModels = [
    'gemini-3.5-flash',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.5-pro',
  ];

  /// Developer / about info.
  static const String developerName = 'Awesome Memo Team';
  static const String developerEmail = 'research.dev33@proton.me';
  static const String repositoryUrl = 'https://github.com/';
  static const String appVersion = '0.1.0';
}

/// SharedPreferences keys.
abstract final class PrefKeys {
  static const String onboardingDone = 'onboarding_done';
  static const String themeMode = 'theme_mode'; // system | light | dark
  static const String geminiModel = 'gemini_model';
  static const String autoClassify = 'auto_classify';
  static const String autoCreateCategory = 'auto_create_category';
  static const String generateSummaries = 'generate_summaries';
}
