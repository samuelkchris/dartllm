// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usage_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UsageStats {

/// Number of tokens in the input prompt.
///
/// For chat completions, this includes all messages in the
/// conversation history after chat template formatting.
 int get promptTokens;/// Number of tokens generated in the response.
 int get completionTokens;
/// Create a copy of UsageStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageStatsCopyWith<UsageStats> get copyWith => _$UsageStatsCopyWithImpl<UsageStats>(this as UsageStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsageStats&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens));
}


@override
int get hashCode => Object.hash(runtimeType,promptTokens,completionTokens);

@override
String toString() {
  return 'UsageStats(promptTokens: $promptTokens, completionTokens: $completionTokens)';
}


}

/// @nodoc
abstract mixin class $UsageStatsCopyWith<$Res>  {
  factory $UsageStatsCopyWith(UsageStats value, $Res Function(UsageStats) _then) = _$UsageStatsCopyWithImpl;
@useResult
$Res call({
 int promptTokens, int completionTokens
});




}
/// @nodoc
class _$UsageStatsCopyWithImpl<$Res>
    implements $UsageStatsCopyWith<$Res> {
  _$UsageStatsCopyWithImpl(this._self, this._then);

  final UsageStats _self;
  final $Res Function(UsageStats) _then;

/// Create a copy of UsageStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? promptTokens = null,Object? completionTokens = null,}) {
  return _then(_self.copyWith(
promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UsageStats].
extension UsageStatsPatterns on UsageStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsageStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsageStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsageStats value)  $default,){
final _that = this;
switch (_that) {
case _UsageStats():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsageStats value)?  $default,){
final _that = this;
switch (_that) {
case _UsageStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int promptTokens,  int completionTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsageStats() when $default != null:
return $default(_that.promptTokens,_that.completionTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int promptTokens,  int completionTokens)  $default,) {final _that = this;
switch (_that) {
case _UsageStats():
return $default(_that.promptTokens,_that.completionTokens);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int promptTokens,  int completionTokens)?  $default,) {final _that = this;
switch (_that) {
case _UsageStats() when $default != null:
return $default(_that.promptTokens,_that.completionTokens);case _:
  return null;

}
}

}

/// @nodoc


class _UsageStats extends UsageStats {
  const _UsageStats({required this.promptTokens, required this.completionTokens}): super._();
  

/// Number of tokens in the input prompt.
///
/// For chat completions, this includes all messages in the
/// conversation history after chat template formatting.
@override final  int promptTokens;
/// Number of tokens generated in the response.
@override final  int completionTokens;

/// Create a copy of UsageStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageStatsCopyWith<_UsageStats> get copyWith => __$UsageStatsCopyWithImpl<_UsageStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsageStats&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens));
}


@override
int get hashCode => Object.hash(runtimeType,promptTokens,completionTokens);

@override
String toString() {
  return 'UsageStats(promptTokens: $promptTokens, completionTokens: $completionTokens)';
}


}

/// @nodoc
abstract mixin class _$UsageStatsCopyWith<$Res> implements $UsageStatsCopyWith<$Res> {
  factory _$UsageStatsCopyWith(_UsageStats value, $Res Function(_UsageStats) _then) = __$UsageStatsCopyWithImpl;
@override @useResult
$Res call({
 int promptTokens, int completionTokens
});




}
/// @nodoc
class __$UsageStatsCopyWithImpl<$Res>
    implements _$UsageStatsCopyWith<$Res> {
  __$UsageStatsCopyWithImpl(this._self, this._then);

  final _UsageStats _self;
  final $Res Function(_UsageStats) _then;

/// Create a copy of UsageStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? promptTokens = null,Object? completionTokens = null,}) {
  return _then(_UsageStats(
promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
