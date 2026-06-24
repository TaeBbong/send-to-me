import 'package:awesome_memo/core/utils/korean_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wj = '⁠'; // WORD JOINER

  group('keepAll', () {
    test('joins the characters of a Korean word with WORD JOINER', () {
      expect(keepAll('안녕'), '안$wj녕');
    });

    test('breaks only at spaces between words', () {
      expect(keepAll('안녕 세상'), '안$wj녕 세$wj상');
    });

    test('leaves pure ASCII words untouched', () {
      expect(keepAll('hello world'), 'hello world');
    });

    test('leaves a URL token breakable (no joiners inserted)', () {
      const url = 'https://example.com/very/long/path';
      expect(keepAll('link $url'), 'link $url');
    });

    test('does not join Korean words longer than maxJoin', () {
      final long = '가' * 21; // 21 > default maxJoin of 20
      expect(keepAll(long), long);
    });

    test('joins a Korean word exactly at the maxJoin boundary', () {
      final word = '가' * 20;
      final joined = List.filled(20, '가').join(wj);
      expect(keepAll(word), joined);
    });

    test('respects a custom maxJoin', () {
      expect(keepAll('안녕하세요', maxJoin: 3), '안녕하세요');
      expect(keepAll('안녕', maxJoin: 3), '안$wj녕');
    });

    test('preserves explicit newlines', () {
      expect(keepAll('안녕\n세상'), '안$wj녕\n세$wj상');
    });

    test('treats a mixed Korean+ASCII word as Korean (joined)', () {
      expect(keepAll('AI로'), 'A${wj}I$wj로');
    });

    test('returns empty string unchanged', () {
      expect(keepAll(''), '');
    });
  });
}
