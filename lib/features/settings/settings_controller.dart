import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import 'settings_state.dart';

/// Reads/writes app settings backed by [SharedPreferences].
class SettingsController extends Notifier<SettingsState> {
  late final SharedPreferences _prefs = ref.read(sharedPreferencesProvider);

  @override
  SettingsState build() {
    return SettingsState(
      themeMode: SettingsState.themeModeFromName(
        _prefs.getString(PrefKeys.themeMode),
      ),
      geminiModel:
          _prefs.getString(PrefKeys.geminiModel) ?? AppConstants.defaultModel,
      autoClassify: _prefs.getBool(PrefKeys.autoClassify) ?? true,
      autoCreateCategory: _prefs.getBool(PrefKeys.autoCreateCategory) ?? true,
      generateSummaries: _prefs.getBool(PrefKeys.generateSummaries) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(PrefKeys.themeMode, SettingsState.themeModeName(mode));
  }

  Future<void> setModel(String model) async {
    state = state.copyWith(geminiModel: model);
    await _prefs.setString(PrefKeys.geminiModel, model);
  }

  Future<void> setAutoClassify(bool value) async {
    state = state.copyWith(autoClassify: value);
    await _prefs.setBool(PrefKeys.autoClassify, value);
  }

  Future<void> setAutoCreateCategory(bool value) async {
    state = state.copyWith(autoCreateCategory: value);
    await _prefs.setBool(PrefKeys.autoCreateCategory, value);
  }

  Future<void> setGenerateSummaries(bool value) async {
    state = state.copyWith(generateSummaries: value);
    await _prefs.setBool(PrefKeys.generateSummaries, value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
