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
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get classifiedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Caches the generative-UI output (raw A2UI text) per category so a room's
/// AI-rendered layout is generated once and replayed on later visits instead of
/// re-calling the LLM every time.
@DataClassName('GenUiCacheRow')
class GenUiCaches extends Table {
  TextColumn get categoryId => text()();

  /// The concatenated A2UI protocol text the model produced.
  TextColumn get payload => text()();

  /// Signature of the memo set the payload was built from, to detect staleness.
  TextColumn get signature => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {categoryId};
}

@DriftDatabase(tables: [Categories, Memos, GenUiCaches])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'awesome_memo'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(genUiCaches);
    },
  );
}
