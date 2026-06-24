import 'package:awesome_memo/data/local/app_database.dart';
import 'package:awesome_memo/data/mappers/category_mapper.dart';
import 'package:awesome_memo/data/mappers/memo_mapper.dart';
import 'package:awesome_memo/domain/entities/category.dart';
import 'package:awesome_memo/domain/entities/enums.dart';
import 'package:awesome_memo/domain/entities/memo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('Memo mapper round-trip', () {
    test('preserves every field through companion → DB → domain', () async {
      final memo = Memo(
        id: 'm1',
        content: 'buy milk https://shop.com',
        status: MemoStatus.classified,
        createdAt: DateTime(2026, 6, 1, 9),
        categoryId: 'cat-1',
        summary: 'a summary',
        sourceUrl: 'https://shop.com',
        isDone: true,
        doneAt: DateTime(2026, 6, 2, 10),
        dueAt: DateTime(2026, 6, 3),
        classifiedAt: DateTime(2026, 6, 1, 9, 30),
        linkTitle: 'Shop',
      );

      await db.into(db.memos).insert(memo.toCompanion());
      final row = await (db.select(db.memos)
            ..where((t) => t.id.equals('m1')))
          .getSingle();

      expect(row.toDomain(), memo);
    });

    test('nullable fields survive as null', () async {
      final memo = Memo(
        id: 'm2',
        content: 'plain',
        status: MemoStatus.pending,
        createdAt: DateTime(2026, 6, 1),
      );

      await db.into(db.memos).insert(memo.toCompanion());
      final row = await (db.select(db.memos)
            ..where((t) => t.id.equals('m2')))
          .getSingle();
      final back = row.toDomain();

      expect(back.categoryId, isNull);
      expect(back.summary, isNull);
      expect(back.dueAt, isNull);
      expect(back.linkTitle, isNull);
      expect(back.isDone, isFalse);
    });

    test('an unknown stored status maps to pending', () async {
      await db.into(db.memos).insert(
            MemosCompanion.insert(
              id: 'm3',
              content: 'x',
              status: 'corrupted',
              createdAt: DateTime(2026, 6, 1),
            ),
          );
      final row = await (db.select(db.memos)
            ..where((t) => t.id.equals('m3')))
          .getSingle();
      expect(row.toDomain().status, MemoStatus.pending);
    });
  });

  group('Category mapper round-trip', () {
    test('preserves every field through companion → DB → domain', () async {
      final category = Category(
        id: 'c1',
        name: '쇼핑',
        emoji: '🛒',
        kind: CategoryKind.todo,
        description: '사야 할 것',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 2),
        archived: true,
      );

      await db.into(db.categories).insert(category.toCompanion());
      final row = await (db.select(db.categories)
            ..where((t) => t.id.equals('c1')))
          .getSingle();

      expect(row.toDomain(), category);
    });

    test('an unknown stored kind maps to note', () async {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'c2',
              name: 'x',
              emoji: '❓',
              kind: 'corrupted',
              createdAt: DateTime(2026, 6, 1),
              updatedAt: DateTime(2026, 6, 1),
            ),
          );
      final row = await (db.select(db.categories)
            ..where((t) => t.id.equals('c2')))
          .getSingle();
      expect(row.toDomain().kind, CategoryKind.note);
    });
  });
}
