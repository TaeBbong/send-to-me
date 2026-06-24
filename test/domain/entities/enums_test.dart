import 'package:awesome_memo/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryKind.fromName', () {
    test('parses every known name', () {
      expect(CategoryKind.fromName('todo'), CategoryKind.todo);
      expect(CategoryKind.fromName('reference'), CategoryKind.reference);
      expect(CategoryKind.fromName('idea'), CategoryKind.idea);
      expect(CategoryKind.fromName('note'), CategoryKind.note);
    });

    test('falls back to note for unknown or null', () {
      expect(CategoryKind.fromName('garbage'), CategoryKind.note);
      expect(CategoryKind.fromName(null), CategoryKind.note);
      expect(CategoryKind.fromName(''), CategoryKind.note);
    });
  });

  group('CategoryKind presentation', () {
    test('each kind has a distinct default emoji, label and tag', () {
      final emojis = CategoryKind.values.map((k) => k.defaultEmoji).toSet();
      final labels = CategoryKind.values.map((k) => k.label).toSet();
      final tags = CategoryKind.values.map((k) => k.tag).toSet();
      expect(emojis, hasLength(CategoryKind.values.length));
      expect(labels, hasLength(CategoryKind.values.length));
      expect(tags, hasLength(CategoryKind.values.length));
    });

    test('exposes the expected todo presentation', () {
      expect(CategoryKind.todo.defaultEmoji, '✅');
      expect(CategoryKind.todo.label, '할 일');
      expect(CategoryKind.todo.tag, 'TODO');
    });
  });

  group('MemoStatus.fromName', () {
    test('parses every known name', () {
      expect(MemoStatus.fromName('pending'), MemoStatus.pending);
      expect(MemoStatus.fromName('processing'), MemoStatus.processing);
      expect(MemoStatus.fromName('classified'), MemoStatus.classified);
      expect(MemoStatus.fromName('failed'), MemoStatus.failed);
    });

    test('falls back to pending for unknown or null', () {
      expect(MemoStatus.fromName('???'), MemoStatus.pending);
      expect(MemoStatus.fromName(null), MemoStatus.pending);
    });
  });
}
