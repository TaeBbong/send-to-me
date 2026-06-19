/// App-wide constant values and identifiers.
abstract final class AppConstants {
  static const String appName = 'Awesome Memo';
  static const String appTagline = '생각나면 톡, 정리는 AI가.';

  /// Default Gemini model and its fallback, used by the classification service.
  /// Both are overridable from Settings.
  ///
  /// `gemini-2.5-flash-lite` is the fastest/cheapest model — classification is a
  /// lightweight task, so the lite model keeps latency low. `gemini-2.5-flash`
  /// is the safe fallback if the primary errors for a given project/region.
  static const String defaultModel = 'gemini-2.5-flash-lite';
  static const String fallbackModel = 'gemini-2.5-flash';

  /// How long a single classification LLM call may run before we give up and
  /// mark the memo failed. The lite model normally answers in a few seconds;
  /// this generous ceiling only catches calls that are truly stuck (e.g. a slow
  /// or flaky network) so they don't fail prematurely.
  static const Duration classifyTimeout = Duration(minutes: 1);

  /// Max number of memos classified concurrently when several are pending.
  static const int classifyConcurrency = 4;

  /// Selectable models surfaced in Settings, lightest first.
  static const List<String> selectableModels = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.5-pro',
  ];

  /// Developer / about info.
  static const String developerName = 'TaeBbong';
  static const String developerEmail = 'mok05289@korea.ac.kr';
  static const String repositoryUrl = 'https://github.com/TaeBbong/send-to-me';
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
