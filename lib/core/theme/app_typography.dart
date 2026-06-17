import 'package:flutter/material.dart';

/// Typography for Awesome Memo.
///
/// We deliberately use the platform default font (San Francisco on iOS, Roboto
/// on Android) for a clean, native messenger feel — no bundled font assets.
/// The scale below is a compact, readable set tuned for chat density.
abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      // Screen titles / app bar.
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      // Memo / message body.
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      // Metadata / timestamps.
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: secondary,
      ),
    );
  }
}
