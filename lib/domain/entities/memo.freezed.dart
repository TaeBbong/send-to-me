// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Memo {

 String get id; String get content; MemoStatus get status; DateTime get createdAt;/// Assigned by the classifier; null while pending/failed.
 String? get categoryId;/// Optional LLM-generated summary (mainly for reference/link memos).
 String? get summary;/// First URL detected in [content], if any.
 String? get sourceUrl;/// Checklist state, meaningful when the memo lives in a TODO category.
 bool get isDone;/// Optional due date the classifier may extract from the text.
 DateTime? get dueAt;/// When the memo was successfully classified.
 DateTime? get classifiedAt;
/// Create a copy of Memo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoCopyWith<Memo> get copyWith => _$MemoCopyWithImpl<Memo>(this as Memo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Memo&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.classifiedAt, classifiedAt) || other.classifiedAt == classifiedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,status,createdAt,categoryId,summary,sourceUrl,isDone,dueAt,classifiedAt);

@override
String toString() {
  return 'Memo(id: $id, content: $content, status: $status, createdAt: $createdAt, categoryId: $categoryId, summary: $summary, sourceUrl: $sourceUrl, isDone: $isDone, dueAt: $dueAt, classifiedAt: $classifiedAt)';
}


}

/// @nodoc
abstract mixin class $MemoCopyWith<$Res>  {
  factory $MemoCopyWith(Memo value, $Res Function(Memo) _then) = _$MemoCopyWithImpl;
@useResult
$Res call({
 String id, String content, MemoStatus status, DateTime createdAt, String? categoryId, String? summary, String? sourceUrl, bool isDone, DateTime? dueAt, DateTime? classifiedAt
});




}
/// @nodoc
class _$MemoCopyWithImpl<$Res>
    implements $MemoCopyWith<$Res> {
  _$MemoCopyWithImpl(this._self, this._then);

  final Memo _self;
  final $Res Function(Memo) _then;

/// Create a copy of Memo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? status = null,Object? createdAt = null,Object? categoryId = freezed,Object? summary = freezed,Object? sourceUrl = freezed,Object? isDone = null,Object? dueAt = freezed,Object? classifiedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemoStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,classifiedAt: freezed == classifiedAt ? _self.classifiedAt : classifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Memo].
extension MemoPatterns on Memo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Memo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Memo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Memo value)  $default,){
final _that = this;
switch (_that) {
case _Memo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Memo value)?  $default,){
final _that = this;
switch (_that) {
case _Memo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  MemoStatus status,  DateTime createdAt,  String? categoryId,  String? summary,  String? sourceUrl,  bool isDone,  DateTime? dueAt,  DateTime? classifiedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Memo() when $default != null:
return $default(_that.id,_that.content,_that.status,_that.createdAt,_that.categoryId,_that.summary,_that.sourceUrl,_that.isDone,_that.dueAt,_that.classifiedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  MemoStatus status,  DateTime createdAt,  String? categoryId,  String? summary,  String? sourceUrl,  bool isDone,  DateTime? dueAt,  DateTime? classifiedAt)  $default,) {final _that = this;
switch (_that) {
case _Memo():
return $default(_that.id,_that.content,_that.status,_that.createdAt,_that.categoryId,_that.summary,_that.sourceUrl,_that.isDone,_that.dueAt,_that.classifiedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  MemoStatus status,  DateTime createdAt,  String? categoryId,  String? summary,  String? sourceUrl,  bool isDone,  DateTime? dueAt,  DateTime? classifiedAt)?  $default,) {final _that = this;
switch (_that) {
case _Memo() when $default != null:
return $default(_that.id,_that.content,_that.status,_that.createdAt,_that.categoryId,_that.summary,_that.sourceUrl,_that.isDone,_that.dueAt,_that.classifiedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Memo extends Memo {
  const _Memo({required this.id, required this.content, required this.status, required this.createdAt, this.categoryId, this.summary, this.sourceUrl, this.isDone = false, this.dueAt, this.classifiedAt}): super._();
  

@override final  String id;
@override final  String content;
@override final  MemoStatus status;
@override final  DateTime createdAt;
/// Assigned by the classifier; null while pending/failed.
@override final  String? categoryId;
/// Optional LLM-generated summary (mainly for reference/link memos).
@override final  String? summary;
/// First URL detected in [content], if any.
@override final  String? sourceUrl;
/// Checklist state, meaningful when the memo lives in a TODO category.
@override@JsonKey() final  bool isDone;
/// Optional due date the classifier may extract from the text.
@override final  DateTime? dueAt;
/// When the memo was successfully classified.
@override final  DateTime? classifiedAt;

/// Create a copy of Memo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoCopyWith<_Memo> get copyWith => __$MemoCopyWithImpl<_Memo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Memo&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.classifiedAt, classifiedAt) || other.classifiedAt == classifiedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,status,createdAt,categoryId,summary,sourceUrl,isDone,dueAt,classifiedAt);

@override
String toString() {
  return 'Memo(id: $id, content: $content, status: $status, createdAt: $createdAt, categoryId: $categoryId, summary: $summary, sourceUrl: $sourceUrl, isDone: $isDone, dueAt: $dueAt, classifiedAt: $classifiedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoCopyWith<$Res> implements $MemoCopyWith<$Res> {
  factory _$MemoCopyWith(_Memo value, $Res Function(_Memo) _then) = __$MemoCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, MemoStatus status, DateTime createdAt, String? categoryId, String? summary, String? sourceUrl, bool isDone, DateTime? dueAt, DateTime? classifiedAt
});




}
/// @nodoc
class __$MemoCopyWithImpl<$Res>
    implements _$MemoCopyWith<$Res> {
  __$MemoCopyWithImpl(this._self, this._then);

  final _Memo _self;
  final $Res Function(_Memo) _then;

/// Create a copy of Memo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? status = null,Object? createdAt = null,Object? categoryId = freezed,Object? summary = freezed,Object? sourceUrl = freezed,Object? isDone = null,Object? dueAt = freezed,Object? classifiedAt = freezed,}) {
  return _then(_Memo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemoStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,classifiedAt: freezed == classifiedAt ? _self.classifiedAt : classifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
