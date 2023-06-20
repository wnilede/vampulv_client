// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'synchronized_data_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SynchronizedDataChange _$SynchronizedDataChangeFromJson(
    Map<String, dynamic> json) {
  return _SynchronizedDataChange.fromJson(json);
}

/// @nodoc
mixin _$SynchronizedDataChange {
  SynchronizedDataChangeType get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int? get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SynchronizedDataChangeCopyWith<SynchronizedDataChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SynchronizedDataChangeCopyWith<$Res> {
  factory $SynchronizedDataChangeCopyWith(SynchronizedDataChange value,
          $Res Function(SynchronizedDataChange) then) =
      _$SynchronizedDataChangeCopyWithImpl<$Res, SynchronizedDataChange>;
  @useResult
  $Res call({SynchronizedDataChangeType type, String message, int? timestamp});
}

/// @nodoc
class _$SynchronizedDataChangeCopyWithImpl<$Res,
        $Val extends SynchronizedDataChange>
    implements $SynchronizedDataChangeCopyWith<$Res> {
  _$SynchronizedDataChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SynchronizedDataChangeType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SynchronizedDataChangeCopyWith<$Res>
    implements $SynchronizedDataChangeCopyWith<$Res> {
  factory _$$_SynchronizedDataChangeCopyWith(_$_SynchronizedDataChange value,
          $Res Function(_$_SynchronizedDataChange) then) =
      __$$_SynchronizedDataChangeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SynchronizedDataChangeType type, String message, int? timestamp});
}

/// @nodoc
class __$$_SynchronizedDataChangeCopyWithImpl<$Res>
    extends _$SynchronizedDataChangeCopyWithImpl<$Res,
        _$_SynchronizedDataChange>
    implements _$$_SynchronizedDataChangeCopyWith<$Res> {
  __$$_SynchronizedDataChangeCopyWithImpl(_$_SynchronizedDataChange _value,
      $Res Function(_$_SynchronizedDataChange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$_SynchronizedDataChange(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SynchronizedDataChangeType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SynchronizedDataChange implements _SynchronizedDataChange {
  const _$_SynchronizedDataChange(
      {required this.type, required this.message, this.timestamp});

  factory _$_SynchronizedDataChange.fromJson(Map<String, dynamic> json) =>
      _$$_SynchronizedDataChangeFromJson(json);

  @override
  final SynchronizedDataChangeType type;
  @override
  final String message;
  @override
  final int? timestamp;

  @override
  String toString() {
    return 'SynchronizedDataChange(type: $type, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SynchronizedDataChange &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type, message, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SynchronizedDataChangeCopyWith<_$_SynchronizedDataChange> get copyWith =>
      __$$_SynchronizedDataChangeCopyWithImpl<_$_SynchronizedDataChange>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SynchronizedDataChangeToJson(
      this,
    );
  }
}

abstract class _SynchronizedDataChange implements SynchronizedDataChange {
  const factory _SynchronizedDataChange(
      {required final SynchronizedDataChangeType type,
      required final String message,
      final int? timestamp}) = _$_SynchronizedDataChange;

  factory _SynchronizedDataChange.fromJson(Map<String, dynamic> json) =
      _$_SynchronizedDataChange.fromJson;

  @override
  SynchronizedDataChangeType get type;
  @override
  String get message;
  @override
  int? get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$_SynchronizedDataChangeCopyWith<_$_SynchronizedDataChange> get copyWith =>
      throw _privateConstructorUsedError;
}
