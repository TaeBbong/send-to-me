import 'package:flutter/material.dart';

/// A [ThemeExtension] that carries app-specific color tokens that do not map
/// cleanly onto Material's [ColorScheme] — most importantly the chat bubble
/// colors and the palette used to tint category "chat rooms".
///
/// Access it with `Theme.of(context).extension<AppColors>()!` or the
/// convenience getter `context.appColors` (see `theme_extensions.dart`).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.chatBackground,
    required this.outgoingBubble,
    required this.onOutgoingBubble,
    required this.incomingBubble,
    required this.onIncomingBubble,
    required this.systemBubble,
    required this.onSystemBubble,
    required this.textSecondary,
    required this.divider,
    required this.categoryPalette,
  });

  /// Background of chat surfaces (slightly off from [ColorScheme.surface]).
  final Color chatBackground;

  /// "Me" bubble (note-to-self / user authored memo).
  final Color outgoingBubble;
  final Color onOutgoingBubble;

  /// Assistant ("Memo bot") bubble.
  final Color incomingBubble;
  final Color onIncomingBubble;

  /// Inline system notices (e.g. "분류됨 · 할 일").
  final Color systemBubble;
  final Color onSystemBubble;

  /// Muted secondary text (timestamps, metadata).
  final Color textSecondary;

  /// Hairline dividers.
  final Color divider;

  /// Accent palette used to color category avatars/rooms deterministically.
  final List<Color> categoryPalette;

  /// Picks a stable accent color for a category from its [seed] (e.g. id).
  Color categoryColor(String seed) {
    if (categoryPalette.isEmpty) return outgoingBubble;
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    return categoryPalette[hash % categoryPalette.length];
  }

  @override
  AppColors copyWith({
    Color? chatBackground,
    Color? outgoingBubble,
    Color? onOutgoingBubble,
    Color? incomingBubble,
    Color? onIncomingBubble,
    Color? systemBubble,
    Color? onSystemBubble,
    Color? textSecondary,
    Color? divider,
    List<Color>? categoryPalette,
  }) {
    return AppColors(
      chatBackground: chatBackground ?? this.chatBackground,
      outgoingBubble: outgoingBubble ?? this.outgoingBubble,
      onOutgoingBubble: onOutgoingBubble ?? this.onOutgoingBubble,
      incomingBubble: incomingBubble ?? this.incomingBubble,
      onIncomingBubble: onIncomingBubble ?? this.onIncomingBubble,
      systemBubble: systemBubble ?? this.systemBubble,
      onSystemBubble: onSystemBubble ?? this.onSystemBubble,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      categoryPalette: categoryPalette ?? this.categoryPalette,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      chatBackground: Color.lerp(chatBackground, other.chatBackground, t)!,
      outgoingBubble: Color.lerp(outgoingBubble, other.outgoingBubble, t)!,
      onOutgoingBubble: Color.lerp(onOutgoingBubble, other.onOutgoingBubble, t)!,
      incomingBubble: Color.lerp(incomingBubble, other.incomingBubble, t)!,
      onIncomingBubble: Color.lerp(onIncomingBubble, other.onIncomingBubble, t)!,
      systemBubble: Color.lerp(systemBubble, other.systemBubble, t)!,
      onSystemBubble: Color.lerp(onSystemBubble, other.onSystemBubble, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      categoryPalette: t < 0.5 ? categoryPalette : other.categoryPalette,
    );
  }

  // --- Brand seed ---------------------------------------------------------
  /// Familiar messenger blue used as the brand seed.
  static const Color brandSeed = Color(0xFF3478F6);

  // --- Light tokens -------------------------------------------------------
  static const AppColors light = AppColors(
    chatBackground: Color(0xFFF1F3F5),
    outgoingBubble: Color(0xFF3478F6),
    onOutgoingBubble: Color(0xFFFFFFFF),
    incomingBubble: Color(0xFFFFFFFF),
    onIncomingBubble: Color(0xFF1A1A1C),
    systemBubble: Color(0xFFE7EAEE),
    onSystemBubble: Color(0xFF5A6068),
    textSecondary: Color(0xFF8A8F98),
    divider: Color(0xFFE3E5E8),
    categoryPalette: _palette,
  );

  // --- Dark tokens --------------------------------------------------------
  static const AppColors dark = AppColors(
    chatBackground: Color(0xFF0E0E10),
    outgoingBubble: Color(0xFF3D7DFF),
    onOutgoingBubble: Color(0xFFFFFFFF),
    incomingBubble: Color(0xFF26262A),
    onIncomingBubble: Color(0xFFF2F2F5),
    systemBubble: Color(0xFF202024),
    onSystemBubble: Color(0xFFB7BCC4),
    textSecondary: Color(0xFF8E939B),
    divider: Color(0xFF2A2A2E),
    categoryPalette: _palette,
  );

  /// Muted accent palette shared between light and dark — readable on both.
  static const List<Color> _palette = [
    Color(0xFF5B8DEF), // blue
    Color(0xFF38B59B), // teal
    Color(0xFFEF8C5B), // orange
    Color(0xFF9B6BEF), // violet
    Color(0xFFEF5B7E), // rose
    Color(0xFFE0A93B), // amber
    Color(0xFF4FB0E0), // sky
    Color(0xFF7FB23B), // lime
  ];
}
