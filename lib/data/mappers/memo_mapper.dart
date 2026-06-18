import 'package:drift/drift.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';
import '../local/app_database.dart';

/// Mapping between the Drift [MemoRow] and the domain [Memo].
extension MemoRowX on MemoRow {
  Memo toDomain() => Memo(
    id: id,
    content: content,
    status: MemoStatus.fromName(status),
    createdAt: createdAt,
    categoryId: categoryId,
    summary: summary,
    sourceUrl: sourceUrl,
    isDone: isDone,
    doneAt: doneAt,
    dueAt: dueAt,
    classifiedAt: classifiedAt,
    linkTitle: linkTitle,
  );
}

extension MemoX on Memo {
  MemosCompanion toCompanion() => MemosCompanion(
    id: Value(id),
    content: Value(content),
    status: Value(status.name),
    createdAt: Value(createdAt),
    categoryId: Value(categoryId),
    summary: Value(summary),
    sourceUrl: Value(sourceUrl),
    isDone: Value(isDone),
    doneAt: Value(doneAt),
    dueAt: Value(dueAt),
    classifiedAt: Value(classifiedAt),
    linkTitle: Value(linkTitle),
  );
}
