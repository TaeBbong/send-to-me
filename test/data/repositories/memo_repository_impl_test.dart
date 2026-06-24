import 'package:awesome_memo/data/local/app_database.dart';
import 'package:awesome_memo/data/repositories/memo_repository_impl.dart';
import 'package:awesome_memo/domain/entities/enums.dart';
import 'package:awesome_memo/domain/entities/memo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Memo _memo(
  String id, {
  MemoStatus status = MemoStatus.pending,
  String? categoryId,
  DateTime? createdAt,
}) {
  return Memo(
    id: id,
    content: 'content $id',
    status: status,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    categoryId: categoryId,
  );
}

void main() {
  late AppDatabase db;
  late MemoRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MemoRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('add then watchAll returns the memo', () async {
    await repo.add(_memo('m1'));
    final memos = await repo.watchAll().first;
    expect(memos.map((m) => m.id), ['m1']);
  });

  test('add is an upsert (insertOnConflictUpdate)', () async {
    await repo.add(_memo('m1'));
    await repo.add(_memo('m1', status: MemoStatus.classified));
    final memos = await repo.watchAll().first;
    expect(memos, hasLength(1));
    expect(memos.single.status, MemoStatus.classified);
  });

  test('watchAll orders by createdAt descending', () async {
    await repo.add(_memo('old', createdAt: DateTime(2026, 1, 1)));
    await repo.add(_memo('new', createdAt: DateTime(2026, 2, 1)));
    final memos = await repo.watchAll().first;
    expect(memos.map((m) => m.id), ['new', 'old']);
  });

  test('getPending returns pending and processing, ascending', () async {
    await repo.add(_memo('p2', status: MemoStatus.pending, createdAt: DateTime(2026, 1, 2)));
    await repo.add(_memo('p1', status: MemoStatus.pending, createdAt: DateTime(2026, 1, 1)));
    await repo.add(_memo('proc', status: MemoStatus.processing, createdAt: DateTime(2026, 1, 3)));
    await repo.add(_memo('done', status: MemoStatus.classified));
    await repo.add(_memo('fail', status: MemoStatus.failed));

    final result = await repo.getPending();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull!.map((m) => m.id), ['p1', 'p2', 'proc']);
  });

  test('getByCategory filters and orders ascending', () async {
    await repo.add(_memo('a', categoryId: 'cat', createdAt: DateTime(2026, 1, 2)));
    await repo.add(_memo('b', categoryId: 'cat', createdAt: DateTime(2026, 1, 1)));
    await repo.add(_memo('other', categoryId: 'cat-2'));

    final result = await repo.getByCategory('cat');

    expect(result.valueOrNull!.map((m) => m.id), ['b', 'a']);
  });

  test('update persists changes', () async {
    await repo.add(_memo('m1'));
    final updated = _memo('m1').copyWith(
      status: MemoStatus.classified,
      categoryId: 'cat-1',
      summary: 'summed up',
    );
    await repo.update(updated);

    final memos = await repo.watchByCategory('cat-1').first;
    expect(memos.single.summary, 'summed up');
    expect(memos.single.status, MemoStatus.classified);
  });

  test('delete removes the memo', () async {
    await repo.add(_memo('m1'));
    await repo.delete('m1');
    expect(await repo.watchAll().first, isEmpty);
  });

  test('setDone flips isDone and stamps doneAt', () async {
    await repo.add(_memo('m1'));
    await repo.setDone('m1', true);

    var memo = (await repo.watchAll().first).single;
    expect(memo.isDone, isTrue);
    expect(memo.doneAt, isNotNull);

    await repo.setDone('m1', false);
    memo = (await repo.watchAll().first).single;
    expect(memo.isDone, isFalse);
    expect(memo.doneAt, isNull);
  });

  test('updateLinkTitle stores the title', () async {
    await repo.add(_memo('m1'));
    await repo.updateLinkTitle('m1', 'A Page Title');
    final memo = (await repo.watchAll().first).single;
    expect(memo.linkTitle, 'A Page Title');
  });

  test('watchUnclassified returns memos with no category', () async {
    await repo.add(_memo('none'));
    await repo.add(_memo('has', categoryId: 'cat'));
    final memos = await repo.watchUnclassified().first;
    expect(memos.map((m) => m.id), ['none']);
  });
}
