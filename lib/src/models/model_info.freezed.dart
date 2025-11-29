// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModelInfo {

/// The model's name from metadata or filename.
 String get name;/// Total number of parameters in the model.
///
/// For example, a 7B model has approximately 7,000,000,000 parameters.
 int get parameterCount;/// The model architecture (e.g., "llama", "mistral", "phi").
 String get architecture;/// The quantization method used (e.g., "Q4_K_M", "Q5_K_S", "F16").
 String get quantization;/// The model's native context size in tokens.
///
/// This is the maximum context the model was trained with.
/// May be extended using RoPE scaling in ModelConfig.
 int get contextSize;/// Size of the model's vocabulary (number of unique tokens).
 int get vocabularySize;/// Dimension of token embeddings.
 int get embeddingSize;/// Number of layers in the model.
 int get layerCount;/// Number of attention heads.
 int get headCount;/// Whether this model supports generating embeddings.
 bool get supportsEmbedding;/// Whether this model supports vision/image inputs.
 bool get supportsVision;/// File size in bytes.
 int get fileSizeBytes;/// The chat template format if detected (e.g., "chatml", "llama2").
 String? get chatTemplate;
/// Create a copy of ModelInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelInfoCopyWith<ModelInfo> get copyWith => _$ModelInfoCopyWithImpl<ModelInfo>(this as ModelInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.parameterCount, parameterCount) || other.parameterCount == parameterCount)&&(identical(other.architecture, architecture) || other.architecture == architecture)&&(identical(other.quantization, quantization) || other.quantization == quantization)&&(identical(other.contextSize, contextSize) || other.contextSize == contextSize)&&(identical(other.vocabularySize, vocabularySize) || other.vocabularySize == vocabularySize)&&(identical(other.embeddingSize, embeddingSize) || other.embeddingSize == embeddingSize)&&(identical(other.layerCount, layerCount) || other.layerCount == layerCount)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.supportsEmbedding, supportsEmbedding) || other.supportsEmbedding == supportsEmbedding)&&(identical(other.supportsVision, supportsVision) || other.supportsVision == supportsVision)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.chatTemplate, chatTemplate) || other.chatTemplate == chatTemplate));
}


@override
int get hashCode => Object.hash(runtimeType,name,parameterCount,architecture,quantization,contextSize,vocabularySize,embeddingSize,layerCount,headCount,supportsEmbedding,supportsVision,fileSizeBytes,chatTemplate);

@override
String toString() {
  return 'ModelInfo(name: $name, parameterCount: $parameterCount, architecture: $architecture, quantization: $quantization, contextSize: $contextSize, vocabularySize: $vocabularySize, embeddingSize: $embeddingSize, layerCount: $layerCount, headCount: $headCount, supportsEmbedding: $supportsEmbedding, supportsVision: $supportsVision, fileSizeBytes: $fileSizeBytes, chatTemplate: $chatTemplate)';
}


}

/// @nodoc
abstract mixin class $ModelInfoCopyWith<$Res>  {
  factory $ModelInfoCopyWith(ModelInfo value, $Res Function(ModelInfo) _then) = _$ModelInfoCopyWithImpl;
@useResult
$Res call({
 String name, int parameterCount, String architecture, String quantization, int contextSize, int vocabularySize, int embeddingSize, int layerCount, int headCount, bool supportsEmbedding, bool supportsVision, int fileSizeBytes, String? chatTemplate
});




}
/// @nodoc
class _$ModelInfoCopyWithImpl<$Res>
    implements $ModelInfoCopyWith<$Res> {
  _$ModelInfoCopyWithImpl(this._self, this._then);

  final ModelInfo _self;
  final $Res Function(ModelInfo) _then;

/// Create a copy of ModelInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? parameterCount = null,Object? architecture = null,Object? quantization = null,Object? contextSize = null,Object? vocabularySize = null,Object? embeddingSize = null,Object? layerCount = null,Object? headCount = null,Object? supportsEmbedding = null,Object? supportsVision = null,Object? fileSizeBytes = null,Object? chatTemplate = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parameterCount: null == parameterCount ? _self.parameterCount : parameterCount // ignore: cast_nullable_to_non_nullable
as int,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,quantization: null == quantization ? _self.quantization : quantization // ignore: cast_nullable_to_non_nullable
as String,contextSize: null == contextSize ? _self.contextSize : contextSize // ignore: cast_nullable_to_non_nullable
as int,vocabularySize: null == vocabularySize ? _self.vocabularySize : vocabularySize // ignore: cast_nullable_to_non_nullable
as int,embeddingSize: null == embeddingSize ? _self.embeddingSize : embeddingSize // ignore: cast_nullable_to_non_nullable
as int,layerCount: null == layerCount ? _self.layerCount : layerCount // ignore: cast_nullable_to_non_nullable
as int,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,supportsEmbedding: null == supportsEmbedding ? _self.supportsEmbedding : supportsEmbedding // ignore: cast_nullable_to_non_nullable
as bool,supportsVision: null == supportsVision ? _self.supportsVision : supportsVision // ignore: cast_nullable_to_non_nullable
as bool,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,chatTemplate: freezed == chatTemplate ? _self.chatTemplate : chatTemplate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelInfo].
extension ModelInfoPatterns on ModelInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelInfo value)  $default,){
final _that = this;
switch (_that) {
case _ModelInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ModelInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int parameterCount,  String architecture,  String quantization,  int contextSize,  int vocabularySize,  int embeddingSize,  int layerCount,  int headCount,  bool supportsEmbedding,  bool supportsVision,  int fileSizeBytes,  String? chatTemplate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelInfo() when $default != null:
return $default(_that.name,_that.parameterCount,_that.architecture,_that.quantization,_that.contextSize,_that.vocabularySize,_that.embeddingSize,_that.layerCount,_that.headCount,_that.supportsEmbedding,_that.supportsVision,_that.fileSizeBytes,_that.chatTemplate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int parameterCount,  String architecture,  String quantization,  int contextSize,  int vocabularySize,  int embeddingSize,  int layerCount,  int headCount,  bool supportsEmbedding,  bool supportsVision,  int fileSizeBytes,  String? chatTemplate)  $default,) {final _that = this;
switch (_that) {
case _ModelInfo():
return $default(_that.name,_that.parameterCount,_that.architecture,_that.quantization,_that.contextSize,_that.vocabularySize,_that.embeddingSize,_that.layerCount,_that.headCount,_that.supportsEmbedding,_that.supportsVision,_that.fileSizeBytes,_that.chatTemplate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int parameterCount,  String architecture,  String quantization,  int contextSize,  int vocabularySize,  int embeddingSize,  int layerCount,  int headCount,  bool supportsEmbedding,  bool supportsVision,  int fileSizeBytes,  String? chatTemplate)?  $default,) {final _that = this;
switch (_that) {
case _ModelInfo() when $default != null:
return $default(_that.name,_that.parameterCount,_that.architecture,_that.quantization,_that.contextSize,_that.vocabularySize,_that.embeddingSize,_that.layerCount,_that.headCount,_that.supportsEmbedding,_that.supportsVision,_that.fileSizeBytes,_that.chatTemplate);case _:
  return null;

}
}

}

/// @nodoc


class _ModelInfo extends ModelInfo {
  const _ModelInfo({required this.name, required this.parameterCount, required this.architecture, required this.quantization, required this.contextSize, required this.vocabularySize, required this.embeddingSize, required this.layerCount, required this.headCount, this.supportsEmbedding = false, this.supportsVision = false, required this.fileSizeBytes, this.chatTemplate}): super._();
  

/// The model's name from metadata or filename.
@override final  String name;
/// Total number of parameters in the model.
///
/// For example, a 7B model has approximately 7,000,000,000 parameters.
@override final  int parameterCount;
/// The model architecture (e.g., "llama", "mistral", "phi").
@override final  String architecture;
/// The quantization method used (e.g., "Q4_K_M", "Q5_K_S", "F16").
@override final  String quantization;
/// The model's native context size in tokens.
///
/// This is the maximum context the model was trained with.
/// May be extended using RoPE scaling in ModelConfig.
@override final  int contextSize;
/// Size of the model's vocabulary (number of unique tokens).
@override final  int vocabularySize;
/// Dimension of token embeddings.
@override final  int embeddingSize;
/// Number of layers in the model.
@override final  int layerCount;
/// Number of attention heads.
@override final  int headCount;
/// Whether this model supports generating embeddings.
@override@JsonKey() final  bool supportsEmbedding;
/// Whether this model supports vision/image inputs.
@override@JsonKey() final  bool supportsVision;
/// File size in bytes.
@override final  int fileSizeBytes;
/// The chat template format if detected (e.g., "chatml", "llama2").
@override final  String? chatTemplate;

/// Create a copy of ModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelInfoCopyWith<_ModelInfo> get copyWith => __$ModelInfoCopyWithImpl<_ModelInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.parameterCount, parameterCount) || other.parameterCount == parameterCount)&&(identical(other.architecture, architecture) || other.architecture == architecture)&&(identical(other.quantization, quantization) || other.quantization == quantization)&&(identical(other.contextSize, contextSize) || other.contextSize == contextSize)&&(identical(other.vocabularySize, vocabularySize) || other.vocabularySize == vocabularySize)&&(identical(other.embeddingSize, embeddingSize) || other.embeddingSize == embeddingSize)&&(identical(other.layerCount, layerCount) || other.layerCount == layerCount)&&(identical(other.headCount, headCount) || other.headCount == headCount)&&(identical(other.supportsEmbedding, supportsEmbedding) || other.supportsEmbedding == supportsEmbedding)&&(identical(other.supportsVision, supportsVision) || other.supportsVision == supportsVision)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.chatTemplate, chatTemplate) || other.chatTemplate == chatTemplate));
}


@override
int get hashCode => Object.hash(runtimeType,name,parameterCount,architecture,quantization,contextSize,vocabularySize,embeddingSize,layerCount,headCount,supportsEmbedding,supportsVision,fileSizeBytes,chatTemplate);

@override
String toString() {
  return 'ModelInfo(name: $name, parameterCount: $parameterCount, architecture: $architecture, quantization: $quantization, contextSize: $contextSize, vocabularySize: $vocabularySize, embeddingSize: $embeddingSize, layerCount: $layerCount, headCount: $headCount, supportsEmbedding: $supportsEmbedding, supportsVision: $supportsVision, fileSizeBytes: $fileSizeBytes, chatTemplate: $chatTemplate)';
}


}

/// @nodoc
abstract mixin class _$ModelInfoCopyWith<$Res> implements $ModelInfoCopyWith<$Res> {
  factory _$ModelInfoCopyWith(_ModelInfo value, $Res Function(_ModelInfo) _then) = __$ModelInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, int parameterCount, String architecture, String quantization, int contextSize, int vocabularySize, int embeddingSize, int layerCount, int headCount, bool supportsEmbedding, bool supportsVision, int fileSizeBytes, String? chatTemplate
});




}
/// @nodoc
class __$ModelInfoCopyWithImpl<$Res>
    implements _$ModelInfoCopyWith<$Res> {
  __$ModelInfoCopyWithImpl(this._self, this._then);

  final _ModelInfo _self;
  final $Res Function(_ModelInfo) _then;

/// Create a copy of ModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? parameterCount = null,Object? architecture = null,Object? quantization = null,Object? contextSize = null,Object? vocabularySize = null,Object? embeddingSize = null,Object? layerCount = null,Object? headCount = null,Object? supportsEmbedding = null,Object? supportsVision = null,Object? fileSizeBytes = null,Object? chatTemplate = freezed,}) {
  return _then(_ModelInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parameterCount: null == parameterCount ? _self.parameterCount : parameterCount // ignore: cast_nullable_to_non_nullable
as int,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,quantization: null == quantization ? _self.quantization : quantization // ignore: cast_nullable_to_non_nullable
as String,contextSize: null == contextSize ? _self.contextSize : contextSize // ignore: cast_nullable_to_non_nullable
as int,vocabularySize: null == vocabularySize ? _self.vocabularySize : vocabularySize // ignore: cast_nullable_to_non_nullable
as int,embeddingSize: null == embeddingSize ? _self.embeddingSize : embeddingSize // ignore: cast_nullable_to_non_nullable
as int,layerCount: null == layerCount ? _self.layerCount : layerCount // ignore: cast_nullable_to_non_nullable
as int,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,supportsEmbedding: null == supportsEmbedding ? _self.supportsEmbedding : supportsEmbedding // ignore: cast_nullable_to_non_nullable
as bool,supportsVision: null == supportsVision ? _self.supportsVision : supportsVision // ignore: cast_nullable_to_non_nullable
as bool,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,chatTemplate: freezed == chatTemplate ? _self.chatTemplate : chatTemplate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CachedModelInfo {

/// Unique identifier for this cached model.
///
/// Based on the source (HuggingFace repo/file or URL hash).
 String get modelId;/// Absolute path to the cached model file.
 String get filePath;/// Size of the cached file in bytes.
 int get sizeBytes;/// When the model was downloaded.
 DateTime get downloadedAt;/// The original download source URL or HuggingFace reference.
 String get sourceUrl;/// Model metadata if available, null if not yet loaded.
 ModelInfo? get modelInfo;
/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedModelInfoCopyWith<CachedModelInfo> get copyWith => _$CachedModelInfoCopyWithImpl<CachedModelInfo>(this as CachedModelInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedModelInfo&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.modelInfo, modelInfo) || other.modelInfo == modelInfo));
}


@override
int get hashCode => Object.hash(runtimeType,modelId,filePath,sizeBytes,downloadedAt,sourceUrl,modelInfo);

@override
String toString() {
  return 'CachedModelInfo(modelId: $modelId, filePath: $filePath, sizeBytes: $sizeBytes, downloadedAt: $downloadedAt, sourceUrl: $sourceUrl, modelInfo: $modelInfo)';
}


}

/// @nodoc
abstract mixin class $CachedModelInfoCopyWith<$Res>  {
  factory $CachedModelInfoCopyWith(CachedModelInfo value, $Res Function(CachedModelInfo) _then) = _$CachedModelInfoCopyWithImpl;
@useResult
$Res call({
 String modelId, String filePath, int sizeBytes, DateTime downloadedAt, String sourceUrl, ModelInfo? modelInfo
});


$ModelInfoCopyWith<$Res>? get modelInfo;

}
/// @nodoc
class _$CachedModelInfoCopyWithImpl<$Res>
    implements $CachedModelInfoCopyWith<$Res> {
  _$CachedModelInfoCopyWithImpl(this._self, this._then);

  final CachedModelInfo _self;
  final $Res Function(CachedModelInfo) _then;

/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modelId = null,Object? filePath = null,Object? sizeBytes = null,Object? downloadedAt = null,Object? sourceUrl = null,Object? modelInfo = freezed,}) {
  return _then(_self.copyWith(
modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,modelInfo: freezed == modelInfo ? _self.modelInfo : modelInfo // ignore: cast_nullable_to_non_nullable
as ModelInfo?,
  ));
}
/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelInfoCopyWith<$Res>? get modelInfo {
    if (_self.modelInfo == null) {
    return null;
  }

  return $ModelInfoCopyWith<$Res>(_self.modelInfo!, (value) {
    return _then(_self.copyWith(modelInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [CachedModelInfo].
extension CachedModelInfoPatterns on CachedModelInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedModelInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedModelInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedModelInfo value)  $default,){
final _that = this;
switch (_that) {
case _CachedModelInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedModelInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CachedModelInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String modelId,  String filePath,  int sizeBytes,  DateTime downloadedAt,  String sourceUrl,  ModelInfo? modelInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedModelInfo() when $default != null:
return $default(_that.modelId,_that.filePath,_that.sizeBytes,_that.downloadedAt,_that.sourceUrl,_that.modelInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String modelId,  String filePath,  int sizeBytes,  DateTime downloadedAt,  String sourceUrl,  ModelInfo? modelInfo)  $default,) {final _that = this;
switch (_that) {
case _CachedModelInfo():
return $default(_that.modelId,_that.filePath,_that.sizeBytes,_that.downloadedAt,_that.sourceUrl,_that.modelInfo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String modelId,  String filePath,  int sizeBytes,  DateTime downloadedAt,  String sourceUrl,  ModelInfo? modelInfo)?  $default,) {final _that = this;
switch (_that) {
case _CachedModelInfo() when $default != null:
return $default(_that.modelId,_that.filePath,_that.sizeBytes,_that.downloadedAt,_that.sourceUrl,_that.modelInfo);case _:
  return null;

}
}

}

/// @nodoc


class _CachedModelInfo extends CachedModelInfo {
  const _CachedModelInfo({required this.modelId, required this.filePath, required this.sizeBytes, required this.downloadedAt, required this.sourceUrl, this.modelInfo}): super._();
  

/// Unique identifier for this cached model.
///
/// Based on the source (HuggingFace repo/file or URL hash).
@override final  String modelId;
/// Absolute path to the cached model file.
@override final  String filePath;
/// Size of the cached file in bytes.
@override final  int sizeBytes;
/// When the model was downloaded.
@override final  DateTime downloadedAt;
/// The original download source URL or HuggingFace reference.
@override final  String sourceUrl;
/// Model metadata if available, null if not yet loaded.
@override final  ModelInfo? modelInfo;

/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedModelInfoCopyWith<_CachedModelInfo> get copyWith => __$CachedModelInfoCopyWithImpl<_CachedModelInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedModelInfo&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.modelInfo, modelInfo) || other.modelInfo == modelInfo));
}


@override
int get hashCode => Object.hash(runtimeType,modelId,filePath,sizeBytes,downloadedAt,sourceUrl,modelInfo);

@override
String toString() {
  return 'CachedModelInfo(modelId: $modelId, filePath: $filePath, sizeBytes: $sizeBytes, downloadedAt: $downloadedAt, sourceUrl: $sourceUrl, modelInfo: $modelInfo)';
}


}

/// @nodoc
abstract mixin class _$CachedModelInfoCopyWith<$Res> implements $CachedModelInfoCopyWith<$Res> {
  factory _$CachedModelInfoCopyWith(_CachedModelInfo value, $Res Function(_CachedModelInfo) _then) = __$CachedModelInfoCopyWithImpl;
@override @useResult
$Res call({
 String modelId, String filePath, int sizeBytes, DateTime downloadedAt, String sourceUrl, ModelInfo? modelInfo
});


@override $ModelInfoCopyWith<$Res>? get modelInfo;

}
/// @nodoc
class __$CachedModelInfoCopyWithImpl<$Res>
    implements _$CachedModelInfoCopyWith<$Res> {
  __$CachedModelInfoCopyWithImpl(this._self, this._then);

  final _CachedModelInfo _self;
  final $Res Function(_CachedModelInfo) _then;

/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modelId = null,Object? filePath = null,Object? sizeBytes = null,Object? downloadedAt = null,Object? sourceUrl = null,Object? modelInfo = freezed,}) {
  return _then(_CachedModelInfo(
modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,modelInfo: freezed == modelInfo ? _self.modelInfo : modelInfo // ignore: cast_nullable_to_non_nullable
as ModelInfo?,
  ));
}

/// Create a copy of CachedModelInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelInfoCopyWith<$Res>? get modelInfo {
    if (_self.modelInfo == null) {
    return null;
  }

  return $ModelInfoCopyWith<$Res>(_self.modelInfo!, (value) {
    return _then(_self.copyWith(modelInfo: value));
  });
}
}

// dart format on
