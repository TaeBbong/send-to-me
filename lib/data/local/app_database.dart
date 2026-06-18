import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Categories table. Row class is renamed to [CategoryRow] to avoid clashing
/// with the domain `Category` entity.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  TextColumn get kind => text()(); // CategoryKind.name
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Memos table. Row class renamed to [MemoRow] (domain entity is `Memo`).
@DataClassName('MemoRow')
class Memos extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get status => text()(); // MemoStatus.name
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get doneAt => dateTime().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get classifiedAt => dateTime().nullable()();
  TextColumn get linkTitle => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Memos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'awesome_memo'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v3: TODO completion timestamp + fetched link title, and the now-removed
      // generative-UI cache table is dropped.
      if (from < 3) {
        await m.addColumn(memos, memos.doneAt);
        await m.addColumn(memos, memos.linkTitle);
        await m.database.customStatement('DROP TABLE IF EXISTS gen_ui_caches');
      }
    },
  );
}
