import 'package:drift/drift.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';
import '../../domain/repositories/memo_repository.dart';
import '../local/app_database.dart';
import '../mappers/memo_mapper.dart';

class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Memo>> watchAll() {
    final query = _db.select(_db.memos)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Memo>> watchByCategory(String categoryId) {
    final query = _db.select(_db.memos)
      ..where((t) => t.categoryId.equals(categoryId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Memo>> watchUnclassified() {
    final query = _db.select(_db.memos)
      ..where((t) => t.categoryId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Result<List<Memo>>> getPending() async {
    try {
      final query = _db.select(_db.memos)
        ..where(
          (t) =>
              t.status.equals(MemoStatus.pending.name) |
              t.status.equals(MemoStatus.processing.name),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
      final rows = await query.get();
      return Result.ok(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Result.err(StorageFailure('대기 중 메모 조회 실패', cause: e));
    }
  }

  @override
  Future<Result<List<Memo>>> getByCategory(String categoryId) async {
    try {
      final query = _db.select(_db.memos)
        ..where((t) => t.categoryId.equals(categoryId))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
      final rows = await query.get();
      return Result.ok(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Result.err(StorageFailure('카테고리 메모 조회 실패', cause: e));
    }
  }

  @override
  Future<Result<Memo>> add(Memo memo) async {
    try {
      await _db.into(_db.memos).insertOnConflictUpdate(memo.toCompanion());
      return Result.ok(memo);
    } catch (e) {
      return Result.err(StorageFailure('메모 저장 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> update(Memo memo) async {
    try {
      await _db.into(_db.memos).insertOnConflictUpdate(memo.toCompanion());
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('메모 수정 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await (_db.delete(_db.memos)..where((t) => t.id.equals(id))).go();
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('메모 삭제 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> setDone(String id, bool isDone) async {
    try {
      await (_db.update(_db.memos)..where((t) => t.id.equals(id))).write(
        MemosCompanion(
          isDone: Value(isDone),
          doneAt: Value(isDone ? DateTime.now() : null),
        ),
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('완료 상태 변경 실패', cause: e));
    }
  }

  @override
  Future<Result<void>> updateLinkTitle(String id, String title) async {
    try {
      await (_db.update(_db.memos)..where((t) => t.id.equals(id))).write(
        MemosCompanion(linkTitle: Value(title)),
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure('링크 제목 저장 실패', cause: e));
    }
  }
}
