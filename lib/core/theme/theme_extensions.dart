import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Convenience accessors so widgets can read design tokens tersely:
///
/// ```dart
/// final c = context.appColors;
/// final t = context.textTheme;
/// ```
extension ThemeContextX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
