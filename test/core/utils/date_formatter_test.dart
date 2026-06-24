import 'package:awesome_memo/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // DateFormatter uses the 'ko' locale, which must be initialized first.
  setUpAll(() => initializeDateFormatting('ko'));

  group('DateFormatter.time / stamp', () {
    test('formats an afternoon time in Korean', () {
      expect(DateFormatter.time(DateTime(2026, 6, 24, 15, 20)), '오후 3:20');
    });

    test('formats a morning time in Korean', () {
      expect(DateFormatter.time(DateTime(2026, 6, 24, 9, 5)), '오전 9:05');
    });

    test('stamp includes month, day and time', () {
      expect(DateFormatter.stamp(DateTime(2026, 6, 18, 15, 20)), '6월 18일 오후 3:20');
    });
  });

  group('DateFormatter.dateHeader', () {
    test('returns 오늘 for today', () {
      final now = DateTime.now();
      expect(DateFormatter.dateHeader(now), '오늘');
    });

    test('returns 어제 for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.dateHeader(yesterday), '어제');
    });

    test('returns an absolute month/day for older dates', () {
      expect(DateFormatter.dateHeader(DateTime(2026, 6, 18)), startsWith('6월 18일'));
    });
  });

  group('DateFormatter.relative', () {
    test('returns 방금 for under a minute', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 30));
      expect(DateFormatter.relative(dt), '방금');
    });

    test('returns minutes ago under an hour', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.relative(dt), '5분 전');
    });

    test('returns hours ago under a day', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.relative(dt), '3시간 전');
    });

    test('returns days ago under a week', () {
      final dt = DateTime.now().subtract(const Duration(days: 3));
      expect(DateFormatter.relative(dt), '3일 전');
    });

    test('returns an absolute date for a week or more', () {
      final dt = DateTime.now().subtract(const Duration(days: 10));
      expect(DateFormatter.relative(dt), matches(r'^\d{4}\. \d{1,2}\. \d{1,2}\.$'));
    });
  });

  group('DateFormatter.isDifferentDay', () {
    test('is false within the same calendar day', () {
      expect(
        DateFormatter.isDifferentDay(
          DateTime(2026, 6, 24, 1),
          DateTime(2026, 6, 24, 23),
        ),
        isFalse,
      );
    });

    test('is true across midnight', () {
      expect(
        DateFormatter.isDifferentDay(
          DateTime(2026, 6, 24, 23, 59),
          DateTime(2026, 6, 25, 0, 1),
        ),
        isTrue,
      );
    });
  });
}
