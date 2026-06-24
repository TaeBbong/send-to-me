import 'package:awesome_memo/data/local/app_database.dart';
import 'package:awesome_memo/data/repositories/category_repository_impl.dart';
import 'package:awesome_memo/domain/entities/category.dart';
import 'package:awesome_memo/domain/entities/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Category _category(
  String id, {
  String name = 'name',
  CategoryKind kind = CategoryKind.note,
  bool archived = false,
  DateTime? updatedAt,
}) {
  final ts = updatedAt ?? DateTime(2026, 1, 1);
  return Category(
    id: id,
    name: name,
    emoji: '📝',
    kind: kind,
    description: 'about $id',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: ts,
    archived: archived,
  );
}

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('add then getAll returns the category with mapped kind', () async {
    await repo.add(_category('c1', kind: CategoryKind.todo));
    final result = await repo.getAll();
    expect(result.isOk, isTrue);
    expect(result.valueOrNull!.single.kind, CategoryKind.todo);
  });

  test('getAll excludes archived categories', () async {
    await repo.add(_category('live'));
    await repo.add(_category('dead', archived: true));
    final result = await repo.getAll();
    expect(result.valueOrNull!.map((c) => c.id), ['live']);
  });

  test('getAll orders by updatedAt descending', () async {
    await repo.add(_category('old', updatedAt: DateTime(2026, 1, 1)));
    await repo.add(_category('new', updatedAt: DateTime(2026, 2, 1)));
    final result = await repo.getAll();
    expect(result.valueOrNull!.map((c) => c.id), ['new', 'old']);
  });

  test('getById returns the row or null', () async {
    await repo.add(_category('c1'));
    expect((await repo.getById('c1')).valueOrNull!.id, 'c1');
    expect((await repo.getById('missing')).valueOrNull, isNull);
  });

  test('add is an upsert', () async {
    await repo.add(_category('c1', name: 'first'));
    await repo.add(_category('c1', name: 'second'));
    final result = await repo.getAll();
    expect(result.valueOrNull, hasLength(1));
    expect(result.valueOrNull!.single.name, 'second');
  });

  test('update persists changes', () async {
    await repo.add(_category('c1', name: 'before'));
    await repo.update(_category('c1', name: 'after'));
    expect((await repo.getById('c1')).valueOrNull!.name, 'after');
  });

  test('archive hides the category from getAll but keeps the row', () async {
    await repo.add(_category('c1'));
    await repo.archive('c1');
    expect((await repo.getAll()).valueOrNull, isEmpty);
    expect((await repo.getById('c1')).valueOrNull, isNotNull);
  });

  test('delete removes the row entirely', () async {
    await repo.add(_category('c1'));
    await repo.delete('c1');
    expect((await repo.getById('c1')).valueOrNull, isNull);
  });

  test('watchAll emits non-archived, updatedAt-descending', () async {
    await repo.add(_category('a', updatedAt: DateTime(2026, 1, 1)));
    await repo.add(_category('b', updatedAt: DateTime(2026, 2, 1)));
    await repo.add(_category('z', archived: true));
    final categories = await repo.watchAll().first;
    expect(categories.map((c) => c.id), ['b', 'a']);
  });
}
