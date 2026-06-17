import 'package:drift/drift.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/enums.dart';
import '../local/app_database.dart';

/// Mapping between the Drift [CategoryRow] and the domain [Category].
extension CategoryRowX on CategoryRow {
  Category toDomain() => Category(
    id: id,
    name: name,
    emoji: emoji,
    kind: CategoryKind.fromName(kind),
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archived: archived,
  );
}

extension CategoryX on Category {
  CategoriesCompanion toCompanion() => CategoriesCompanion(
    id: Value(id),
    name: Value(name),
    emoji: Value(emoji),
    kind: Value(kind.name),
    description: Value(description),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    archived: Value(archived),
  );
}
