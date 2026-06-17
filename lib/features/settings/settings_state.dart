import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Immutable settings snapshot. Kept as a plain class (no codegen) since it is
/// small and only ever mutated through [copyWith].
@immutable
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.geminiModel = AppConstants.defaultModel,
    this.autoClassify = true,
    this.autoCreateCategory = true,
    this.generateSummaries = true,
  });

  /// Light / dark / follow-system.
  final ThemeMode themeMode;

  /// Selected Gemini model id (see [AppConstants.selectableModels]).
  final String geminiModel;

  /// Master switch for background LLM classification.
  final bool autoClassify;

  /// Whether the classifier may invent new categories when nothing matches.
  final bool autoCreateCategory;

  /// Whether reference/link memos get an LLM summary at save time.
  final bool generateSummaries;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? geminiModel,
    bool? autoClassify,
    bool? autoCreateCategory,
    bool? generateSummaries,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      geminiModel: geminiModel ?? this.geminiModel,
      autoClassify: autoClassify ?? this.autoClassify,
      autoCreateCategory: autoCreateCategory ?? this.autoCreateCategory,
      generateSummaries: generateSummaries ?? this.generateSummaries,
    );
  }

  static ThemeMode themeModeFromName(String? name) => switch (name) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String themeModeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
