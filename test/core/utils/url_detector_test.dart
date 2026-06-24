import 'package:awesome_memo/core/utils/url_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlDetector.hasUrl', () {
    test('detects http and https URLs', () {
      expect(UrlDetector.hasUrl('see https://example.com now'), isTrue);
      expect(UrlDetector.hasUrl('http://example.com'), isTrue);
    });

    test('is false when there is no URL', () {
      expect(UrlDetector.hasUrl('just a plain memo'), isFalse);
      expect(UrlDetector.hasUrl('example.com without scheme'), isFalse);
    });
  });

  group('UrlDetector.extractUrls', () {
    test('returns every URL in order', () {
      final urls = UrlDetector.extractUrls(
        'first https://a.com then https://b.com end',
      );
      expect(urls, ['https://a.com', 'https://b.com']);
    });

    test('returns empty list when none present', () {
      expect(UrlDetector.extractUrls('nothing here'), isEmpty);
    });
  });

  group('UrlDetector.firstUrl', () {
    test('returns the first URL', () {
      expect(
        UrlDetector.firstUrl('go to https://a.com or https://b.com'),
        'https://a.com',
      );
    });

    test('returns null when none present', () {
      expect(UrlDetector.firstUrl('plain text'), isNull);
    });
  });

  group('UrlDetector.decodeInText', () {
    test('percent-decodes Korean inside an embedded URL', () {
      const text = 'link https://velog.io/@me/AI%EB%A1%9C end';
      expect(UrlDetector.decodeInText(text), 'link https://velog.io/@me/AI로 end');
    });

    test('leaves non-URL text untouched', () {
      expect(UrlDetector.decodeInText('no links 100% sure'), 'no links 100% sure');
    });

    test('keeps the original URL when decoding fails', () {
      // A lone "%" with no valid hex pair is invalid percent-encoding.
      const text = 'https://example.com/%zz';
      expect(UrlDetector.decodeInText(text), text);
    });
  });

  group('UrlDetector.pretty', () {
    test('drops the scheme and trailing slash', () {
      expect(UrlDetector.pretty('https://example.com/'), 'example.com');
    });

    test('percent-decodes the path', () {
      expect(
        UrlDetector.pretty('https://velog.io/@me/AI%EB%A1%9C'),
        'velog.io/@me/AI로',
      );
    });

    test('preserves the query string', () {
      expect(
        UrlDetector.pretty('https://youtube.com/watch?v=abc'),
        'youtube.com/watch?v=abc',
      );
    });

    test('falls back to the raw input when host is empty / unparseable', () {
      expect(UrlDetector.pretty('not a url'), 'not a url');
    });
  });
}
