import 'package:awesome_memo/domain/entities/classification_result.dart';
import 'package:awesome_memo/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClassificationResult.fromJson', () {
    test('parses a full "matched existing" payload', () {
      final r = ClassificationResult.fromJson({
        'matchedCategoryId': 'cat-1',
        'summary': 'a short summary',
        'sourceUrl': 'https://a.com',
        'isDone': true,
        'dueAt': '2026-06-24T10:00:00Z',
      });

      expect(r.matchedCategoryId, 'cat-1');
      expect(r.createsNewCategory, isFalse);
      expect(r.summary, 'a short summary');
      expect(r.sourceUrl, 'https://a.com');
      expect(r.isDone, isTrue);
      expect(r.dueAt, DateTime.utc(2026, 6, 24, 10));
    });

    test('parses a "create new category" payload', () {
      final r = ClassificationResult.fromJson({
        'newCategoryName': '쇼핑',
        'newCategoryEmoji': '🛒',
        'newCategoryKind': 'todo',
        'newCategoryDescription': '사야 할 것들',
      });

      expect(r.matchedCategoryId, isNull);
      expect(r.createsNewCategory, isTrue);
      expect(r.newCategoryName, '쇼핑');
      expect(r.newCategoryEmoji, '🛒');
      expect(r.newCategoryKind, CategoryKind.todo);
      expect(r.newCategoryDescription, '사야 할 것들');
    });

    test('treats empty/blank strings as null', () {
      final r = ClassificationResult.fromJson({
        'matchedCategoryId': '   ',
        'summary': '',
      });
      expect(r.matchedCategoryId, isNull);
      expect(r.summary, isNull);
      expect(r.createsNewCategory, isTrue);
    });

    test('an empty matchedCategoryId means createsNewCategory', () {
      final r = ClassificationResult.fromJson({'matchedCategoryId': ''});
      expect(r.createsNewCategory, isTrue);
    });

    test('trims surrounding whitespace from string fields', () {
      final r = ClassificationResult.fromJson({'matchedCategoryId': '  cat-9 '});
      expect(r.matchedCategoryId, 'cat-9');
    });

    test('an invalid newCategoryKind falls back to note', () {
      final r = ClassificationResult.fromJson({'newCategoryKind': 'bogus'});
      expect(r.newCategoryKind, CategoryKind.note);
    });

    test('a null newCategoryKind stays null', () {
      final r = ClassificationResult.fromJson({'newCategoryName': 'x'});
      expect(r.newCategoryKind, isNull);
    });

    test('isDone is only true for a real boolean true', () {
      expect(ClassificationResult.fromJson({'isDone': 'true'}).isDone, isFalse);
      expect(ClassificationResult.fromJson({'isDone': 1}).isDone, isFalse);
      expect(ClassificationResult.fromJson({'isDone': false}).isDone, isFalse);
      expect(ClassificationResult.fromJson({'isDone': true}).isDone, isTrue);
    });

    test('an unparseable dueAt becomes null', () {
      expect(ClassificationResult.fromJson({'dueAt': 'someday'}).dueAt, isNull);
    });

    test('an empty map yields sensible defaults', () {
      final r = ClassificationResult.fromJson({});
      expect(r.matchedCategoryId, isNull);
      expect(r.isDone, isFalse);
      expect(r.dueAt, isNull);
      expect(r.createsNewCategory, isTrue);
    });

    test('coerces non-string scalars via toString', () {
      final r = ClassificationResult.fromJson({'matchedCategoryId': 123});
      expect(r.matchedCategoryId, '123');
    });
  });
}
