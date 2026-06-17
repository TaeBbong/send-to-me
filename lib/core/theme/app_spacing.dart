/// Spacing, radius and elevation tokens for the whole app.
///
/// These are intentionally small and constant so the design language stays
/// consistent everywhere. Use [AppSpacing] for paddings/gaps and [AppRadius]
/// for corner rounding instead of hard-coding magic numbers in widgets.
library;

import 'package:flutter/widgets.dart';

/// 4pt based spacing scale.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Default horizontal screen padding.
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);

  /// Default page padding.
  static const EdgeInsets page = EdgeInsets.all(lg);
}

/// Corner radius scale. Messenger UIs use generous rounding on bubbles.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;

  static const Radius bubble = Radius.circular(lg);
  static const Radius bubbleTail = Radius.circular(xs);
}

/// Animation durations used across the app.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
}
