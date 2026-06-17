import 'package:drift/drift.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../local/app_database.dart';
import '../mappers/category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Category>> watchAll() {
    final query = _db.select(_db.categories)
      ..where((t) => t.archived.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Result<List<Category>>> getAll() async {
    try {
      final query = _db.select(_db.categories)
        ..where((t) => t.archived.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
      final rows = await query.get();
      return Result.ok(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Result.err(StorageFailure('카테고리 조회 실패', cause: e));
    }
  }

  @override
  Future<Result<Category?>> getById(String id) async {
    try {
      final row = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.ok(row?.toDomain());
    } catch (e) {
      return Result.err(StorageFailure('카테고리 조회 실패', cause: e));
    }
  }

  @override
  Future<Result<Category>> add(Category category) async {
    try {
      await _db
          .into(_db.categories)
          .insertOnConflictUpdate(category.toCompanion());
      return Result.ok(category);
    } catch (e) {
      return Result.err(StorageFailure('카테고리 생성 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> update(Category category) async {
    try {
      await _db
          .into(_db.categories)
          .insertOnConflictUpdate(category.toCompanion());
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('카테고리 수정 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> archive(String id) async {
    try {
      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
          archived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('카테고리 보관 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('카테고리 삭제 실패', cause: e));
    }
  }
}
