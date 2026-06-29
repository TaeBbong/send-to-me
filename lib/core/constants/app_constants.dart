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

  /// Timeout for the FIRST classification attempt. Healthy lite responses
  /// usually land within ~3s, so a request pending past this is most likely a
  /// dead idle keep-alive socket (mobile NAT drops it after a few minutes) —
  /// abort fast and retry on a fresh connection ([classifyRetryTimeout]).
  static const Duration classifyTimeout = Duration(seconds: 3);

  /// Timeout for the retry / fallback attempt. It runs on a fresh connection
  /// (so no dead-socket hang) and gets more room for an occasional slow-but-
  /// healthy response. Worst-case wait before a memo falls back to the draft
  /// bucket is therefore ≈ classifyTimeout + classifyRetryTimeout (≈11s).
  static const Duration classifyRetryTimeout = Duration(seconds: 8);

  /// Max number of memos classified concurrently when several are pending.
  static const int classifyConcurrency = 4;

  /// While the app is in the foreground, draft memos are re-classified against
  /// existing categories on this interval (unobtrusive background retry).
  static const Duration autoReclassifyInterval = Duration(minutes: 5);

  /// Fallback "draft" category (note kind). When classification fails or times
  /// out, the memo is filed here instead of being marked failed — no retry, it
  /// just lands somewhere the user can find it.
  static const String draftCategoryId = 'draft';
  static const String draftCategoryName = '미분류';
  static const String draftCategoryEmoji = '🗂️';

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
