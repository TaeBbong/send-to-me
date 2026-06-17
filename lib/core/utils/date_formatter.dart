import 'package:intl/intl.dart';

/// Formatting helpers for chat-style timestamps and date separators.
abstract final class DateFormatter {
  static final DateFormat _time = DateFormat('a h:mm', 'ko');
  static final DateFormat _monthDay = DateFormat('M월 d일 (E)', 'ko');
  static final DateFormat _full = DateFormat('yyyy. M. d.', 'ko');

  /// "오후 3:20" style time, used under bubbles.
  static String time(DateTime dt) => _time.format(dt);

  /// Date header shown between groups of messages.
  static String dateHeader(DateTime dt) {
    final now = DateTime.now();
    final d = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return _monthDay.format(dt);
  }

  /// Relative "last activity" label for room list (e.g. "방금", "3분 전").
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return _full.format(dt);
  }

  /// Whether two timestamps fall on different calendar days.
  static bool isDifferentDay(DateTime a, DateTime b) =>
      a.year != b.year || a.month != b.month || a.day != b.day;
}
