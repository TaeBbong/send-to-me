// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    kind,
    description,
    createdAt,
    updatedAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String emoji;
  final String kind;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.emoji,
    required this.kind,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['kind'] = Variable<String>(kind);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      kind: Value(kind),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      kind: serializer.fromJson<String>(json['kind']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'kind': serializer.toJson<String>(kind),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? emoji,
    String? kind,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    kind: kind ?? this.kind,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archived: archived ?? this.archived,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      kind: data.kind.present ? data.kind.value : this.kind,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('kind: $kind, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    kind,
    description,
    createdAt,
    updatedAt,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.kind == this.kind &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archived == this.archived);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> kind;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> archived;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.kind = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String emoji,
    required String kind,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emoji = Value(emoji),
       kind = Value(kind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? kind,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (kind != null) 'kind': kind,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<String>? kind,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      kind: kind ?? this.kind,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('kind: $kind, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemosTable extends Memos with TableInfo<$MemosTable, MemoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classifiedAtMeta = const VerificationMeta(
    'classifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> classifiedAt = GeneratedColumn<DateTime>(
    'classified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    status,
    createdAt,
    categoryId,
    summary,
    sourceUrl,
    isDone,
    dueAt,
    classifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memos';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('classified_at')) {
      context.handle(
        _classifiedAtMeta,
        classifiedAt.isAcceptableOrUnknown(
          data['classified_at']!,
          _classifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      classifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}classified_at'],
      ),
    );
  }

  @override
  $MemosTable createAlias(String alias) {
    return $MemosTable(attachedDatabase, alias);
  }
}

class MemoRow extends DataClass implements Insertable<MemoRow> {
  final String id;
  final String content;
  final String status;
  final DateTime createdAt;
  final String? categoryId;
  final String? summary;
  final String? sourceUrl;
  final bool isDone;
  final DateTime? dueAt;
  final DateTime? classifiedAt;
  const MemoRow({
    required this.id,
    required this.content,
    required this.status,
    required this.createdAt,
    this.categoryId,
    this.summary,
    this.sourceUrl,
    required this.isDone,
    this.dueAt,
    this.classifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || classifiedAt != null) {
      map['classified_at'] = Variable<DateTime>(classifiedAt);
    }
    return map;
  }

  MemosCompanion toCompanion(bool nullToAbsent) {
    return MemosCompanion(
      id: Value(id),
      content: Value(content),
      status: Value(status),
      createdAt: Value(createdAt),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      isDone: Value(isDone),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      classifiedAt: classifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(classifiedAt),
    );
  }

  factory MemoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoRow(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      summary: serializer.fromJson<String?>(json['summary']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      classifiedAt: serializer.fromJson<DateTime?>(json['classifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'categoryId': serializer.toJson<String?>(categoryId),
      'summary': serializer.toJson<String?>(summary),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'isDone': serializer.toJson<bool>(isDone),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'classifiedAt': serializer.toJson<DateTime?>(classifiedAt),
    };
  }

  MemoRow copyWith({
    String? id,
    String? content,
    String? status,
    DateTime? createdAt,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    bool? isDone,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> classifiedAt = const Value.absent(),
  }) => MemoRow(
    id: id ?? this.id,
    content: content ?? this.content,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    summary: summary.present ? summary.value : this.summary,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    isDone: isDone ?? this.isDone,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    classifiedAt: classifiedAt.present ? classifiedAt.value : this.classifiedAt,
  );
  MemoRow copyWithCompanion(MemosCompanion data) {
    return MemoRow(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      summary: data.summary.present ? data.summary.value : this.summary,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      classifiedAt: data.classifiedAt.present
          ? data.classifiedAt.value
          : this.classifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoRow(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('summary: $summary, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('isDone: $isDone, ')
          ..write('dueAt: $dueAt, ')
          ..write('classifiedAt: $classifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    status,
    createdAt,
    categoryId,
    summary,
    sourceUrl,
    isDone,
    dueAt,
    classifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoRow &&
          other.id == this.id &&
          other.content == this.content &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.categoryId == this.categoryId &&
          other.summary == this.summary &&
          other.sourceUrl == this.sourceUrl &&
          other.isDone == this.isDone &&
          other.dueAt == this.dueAt &&
          other.classifiedAt == this.classifiedAt);
}

class MemosCompanion extends UpdateCompanion<MemoRow> {
  final Value<String> id;
  final Value<String> content;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> categoryId;
  final Value<String?> summary;
  final Value<String?> sourceUrl;
  final Value<bool> isDone;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> classifiedAt;
  final Value<int> rowid;
  const MemosCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.summary = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.isDone = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.classifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemosCompanion.insert({
    required String id,
    required String content,
    required String status,
    required DateTime createdAt,
    this.categoryId = const Value.absent(),
    this.summary = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.isDone = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.classifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<MemoRow> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? categoryId,
    Expression<String>? summary,
    Expression<String>? sourceUrl,
    Expression<bool>? isDone,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? classifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (categoryId != null) 'category_id': categoryId,
      if (summary != null) 'summary': summary,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (isDone != null) 'is_done': isDone,
      if (dueAt != null) 'due_at': dueAt,
      if (classifiedAt != null) 'classified_at': classifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemosCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String?>? categoryId,
    Value<String?>? summary,
    Value<String?>? sourceUrl,
    Value<bool>? isDone,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? classifiedAt,
    Value<int>? rowid,
  }) {
    return MemosCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      summary: summary ?? this.summary,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isDone: isDone ?? this.isDone,
      dueAt: dueAt ?? this.dueAt,
      classifiedAt: classifiedAt ?? this.classifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (classifiedAt.present) {
      map['classified_at'] = Variable<DateTime>(classifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemosCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('summary: $summary, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('isDone: $isDone, ')
          ..write('dueAt: $dueAt, ')
          ..write('classifiedAt: $classifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GenUiCachesTable extends GenUiCaches
    with TableInfo<$GenUiCachesTable, GenUiCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenUiCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    categoryId,
    payload,
    signature,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gen_ui_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<GenUiCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  GenUiCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GenUiCacheRow(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GenUiCachesTable createAlias(String alias) {
    return $GenUiCachesTable(attachedDatabase, alias);
  }
}

class GenUiCacheRow extends DataClass implements Insertable<GenUiCacheRow> {
  final String categoryId;

  /// The concatenated A2UI protocol text the model produced.
  final String payload;

  /// Signature of the memo set the payload was built from, to detect staleness.
  final String signature;
  final DateTime updatedAt;
  const GenUiCacheRow({
    required this.categoryId,
    required this.payload,
    required this.signature,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['payload'] = Variable<String>(payload);
    map['signature'] = Variable<String>(signature);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GenUiCachesCompanion toCompanion(bool nullToAbsent) {
    return GenUiCachesCompanion(
      categoryId: Value(categoryId),
      payload: Value(payload),
      signature: Value(signature),
      updatedAt: Value(updatedAt),
    );
  }

  factory GenUiCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GenUiCacheRow(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      payload: serializer.fromJson<String>(json['payload']),
      signature: serializer.fromJson<String>(json['signature']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'payload': serializer.toJson<String>(payload),
      'signature': serializer.toJson<String>(signature),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GenUiCacheRow copyWith({
    String? categoryId,
    String? payload,
    String? signature,
    DateTime? updatedAt,
  }) => GenUiCacheRow(
    categoryId: categoryId ?? this.categoryId,
    payload: payload ?? this.payload,
    signature: signature ?? this.signature,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GenUiCacheRow copyWithCompanion(GenUiCachesCompanion data) {
    return GenUiCacheRow(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      payload: data.payload.present ? data.payload.value : this.payload,
      signature: data.signature.present ? data.signature.value : this.signature,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GenUiCacheRow(')
          ..write('categoryId: $categoryId, ')
          ..write('payload: $payload, ')
          ..write('signature: $signature, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, payload, signature, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenUiCacheRow &&
          other.categoryId == this.categoryId &&
          other.payload == this.payload &&
          other.signature == this.signature &&
          other.updatedAt == this.updatedAt);
}

class GenUiCachesCompanion extends UpdateCompanion<GenUiCacheRow> {
  final Value<String> categoryId;
  final Value<String> payload;
  final Value<String> signature;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GenUiCachesCompanion({
    this.categoryId = const Value.absent(),
    this.payload = const Value.absent(),
    this.signature = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GenUiCachesCompanion.insert({
    required String categoryId,
    required String payload,
    required String signature,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       payload = Value(payload),
       signature = Value(signature),
       updatedAt = Value(updatedAt);
  static Insertable<GenUiCacheRow> custom({
    Expression<String>? categoryId,
    Expression<String>? payload,
    Expression<String>? signature,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (payload != null) 'payload': payload,
      if (signature != null) 'signature': signature,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GenUiCachesCompanion copyWith({
    Value<String>? categoryId,
    Value<String>? payload,
    Value<String>? signature,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GenUiCachesCompanion(
      categoryId: categoryId ?? this.categoryId,
      payload: payload ?? this.payload,
      signature: signature ?? this.signature,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenUiCachesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('payload: $payload, ')
          ..write('signature: $signature, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MemosTable memos = $MemosTable(this);
  late final $GenUiCachesTable genUiCaches = $GenUiCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    memos,
    genUiCaches,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String emoji,
      required String kind,
      Value<String> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<String> kind,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                kind: kind,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String emoji,
                required String kind,
                Value<String> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                kind: kind,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$MemosTableCreateCompanionBuilder =
    MemosCompanion Function({
      required String id,
      required String content,
      required String status,
      required DateTime createdAt,
      Value<String?> categoryId,
      Value<String?> summary,
      Value<String?> sourceUrl,
      Value<bool> isDone,
      Value<DateTime?> dueAt,
      Value<DateTime?> classifiedAt,
      Value<int> rowid,
    });
typedef $$MemosTableUpdateCompanionBuilder =
    MemosCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String?> categoryId,
      Value<String?> summary,
      Value<String?> sourceUrl,
      Value<bool> isDone,
      Value<DateTime?> dueAt,
      Value<DateTime?> classifiedAt,
      Value<int> rowid,
    });

class $$MemosTableFilterComposer extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get classifiedAt => $composableBuilder(
    column: $table.classifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemosTableOrderingComposer
    extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get classifiedAt => $composableBuilder(
    column: $table.classifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get classifiedAt => $composableBuilder(
    column: $table.classifiedAt,
    builder: (column) => column,
  );
}

class $$MemosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemosTable,
          MemoRow,
          $$MemosTableFilterComposer,
          $$MemosTableOrderingComposer,
          $$MemosTableAnnotationComposer,
          $$MemosTableCreateCompanionBuilder,
          $$MemosTableUpdateCompanionBuilder,
          (MemoRow, BaseReferences<_$AppDatabase, $MemosTable, MemoRow>),
          MemoRow,
          PrefetchHooks Function()
        > {
  $$MemosTableTableManager(_$AppDatabase db, $MemosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> classifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemosCompanion(
                id: id,
                content: content,
                status: status,
                createdAt: createdAt,
                categoryId: categoryId,
                summary: summary,
                sourceUrl: sourceUrl,
                isDone: isDone,
                dueAt: dueAt,
                classifiedAt: classifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required String status,
                required DateTime createdAt,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> classifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemosCompanion.insert(
                id: id,
                content: content,
                status: status,
                createdAt: createdAt,
                categoryId: categoryId,
                summary: summary,
                sourceUrl: sourceUrl,
                isDone: isDone,
                dueAt: dueAt,
                classifiedAt: classifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemosTable,
      MemoRow,
      $$MemosTableFilterComposer,
      $$MemosTableOrderingComposer,
      $$MemosTableAnnotationComposer,
      $$MemosTableCreateCompanionBuilder,
      $$MemosTableUpdateCompanionBuilder,
      (MemoRow, BaseReferences<_$AppDatabase, $MemosTable, MemoRow>),
      MemoRow,
      PrefetchHooks Function()
    >;
typedef $$GenUiCachesTableCreateCompanionBuilder =
    GenUiCachesCompanion Function({
      required String categoryId,
      required String payload,
      required String signature,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GenUiCachesTableUpdateCompanionBuilder =
    GenUiCachesCompanion Function({
      Value<String> categoryId,
      Value<String> payload,
      Value<String> signature,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GenUiCachesTableFilterComposer
    extends Composer<_$AppDatabase, $GenUiCachesTable> {
  $$GenUiCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GenUiCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $GenUiCachesTable> {
  $$GenUiCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GenUiCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GenUiCachesTable> {
  $$GenUiCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GenUiCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GenUiCachesTable,
          GenUiCacheRow,
          $$GenUiCachesTableFilterComposer,
          $$GenUiCachesTableOrderingComposer,
          $$GenUiCachesTableAnnotationComposer,
          $$GenUiCachesTableCreateCompanionBuilder,
          $$GenUiCachesTableUpdateCompanionBuilder,
          (
            GenUiCacheRow,
            BaseReferences<_$AppDatabase, $GenUiCachesTable, GenUiCacheRow>,
          ),
          GenUiCacheRow,
          PrefetchHooks Function()
        > {
  $$GenUiCachesTableTableManager(_$AppDatabase db, $GenUiCachesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenUiCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GenUiCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenUiCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> signature = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GenUiCachesCompanion(
                categoryId: categoryId,
                payload: payload,
                signature: signature,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required String payload,
                required String signature,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GenUiCachesCompanion.insert(
                categoryId: categoryId,
                payload: payload,
                signature: signature,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GenUiCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GenUiCachesTable,
      GenUiCacheRow,
      $$GenUiCachesTableFilterComposer,
      $$GenUiCachesTableOrderingComposer,
      $$GenUiCachesTableAnnotationComposer,
      $$GenUiCachesTableCreateCompanionBuilder,
      $$GenUiCachesTableUpdateCompanionBuilder,
      (
        GenUiCacheRow,
        BaseReferences<_$AppDatabase, $GenUiCachesTable, GenUiCacheRow>,
      ),
      GenUiCacheRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$MemosTableTableManager get memos =>
      $$MemosTableTableManager(_db, _db.memos);
  $$GenUiCachesTableTableManager get genUiCaches =>
      $$GenUiCachesTableTableManager(_db, _db.genUiCaches);
}
