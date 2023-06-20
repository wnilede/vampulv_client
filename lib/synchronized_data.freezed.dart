// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'synchronized_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SynchronizedData _$SynchronizedDataFromJson(Map<String, dynamic> json) {
  return _SynchronizedData.fromJson(json);
}

/// @nodoc
mixin _$SynchronizedData {
  List<ConnectedDevice> get connectedDevices =>
      throw _privateConstructorUsedError;
  Game get game => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SynchronizedDataCopyWith<SynchronizedData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SynchronizedDataCopyWith<$Res> {
  factory $SynchronizedDataCopyWith(
          SynchronizedData value, $Res Function(SynchronizedData) then) =
      _$SynchronizedDataCopyWithImpl<$Res, SynchronizedData>;
  @useResult
  $Res call({List<ConnectedDevice> connectedDevices, Game game});

  $GameCopyWith<$Res> get game;
}

/// @nodoc
class _$SynchronizedDataCopyWithImpl<$Res, $Val extends SynchronizedData>
    implements $SynchronizedDataCopyWith<$Res> {
  _$SynchronizedDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedDevices = null,
    Object? game = null,
  }) {
    return _then(_value.copyWith(
      connectedDevices: null == connectedDevices
          ? _value.connectedDevices
          : connectedDevices // ignore: cast_nullable_to_non_nullable
              as List<ConnectedDevice>,
      game: null == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GameCopyWith<$Res> get game {
    return $GameCopyWith<$Res>(_value.game, (value) {
      return _then(_value.copyWith(game: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SynchronizedDataCopyWith<$Res>
    implements $SynchronizedDataCopyWith<$Res> {
  factory _$$_SynchronizedDataCopyWith(
          _$_SynchronizedData value, $Res Function(_$_SynchronizedData) then) =
      __$$_SynchronizedDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ConnectedDevice> connectedDevices, Game game});

  @override
  $GameCopyWith<$Res> get game;
}

/// @nodoc
class __$$_SynchronizedDataCopyWithImpl<$Res>
    extends _$SynchronizedDataCopyWithImpl<$Res, _$_SynchronizedData>
    implements _$$_SynchronizedDataCopyWith<$Res> {
  __$$_SynchronizedDataCopyWithImpl(
      _$_SynchronizedData _value, $Res Function(_$_SynchronizedData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedDevices = null,
    Object? game = null,
  }) {
    return _then(_$_SynchronizedData(
      connectedDevices: null == connectedDevices
          ? _value._connectedDevices
          : connectedDevices // ignore: cast_nullable_to_non_nullable
              as List<ConnectedDevice>,
      game: null == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SynchronizedData extends _SynchronizedData {
  const _$_SynchronizedData(
      {required final List<ConnectedDevice> connectedDevices,
      required this.game})
      : _connectedDevices = connectedDevices,
        super._();

  factory _$_SynchronizedData.fromJson(Map<String, dynamic> json) =>
      _$$_SynchronizedDataFromJson(json);

  final List<ConnectedDevice> _connectedDevices;
  @override
  List<ConnectedDevice> get connectedDevices {
    if (_connectedDevices is EqualUnmodifiableListView)
      return _connectedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_connectedDevices);
  }

  @override
  final Game game;

  @override
  String toString() {
    return 'SynchronizedData(connectedDevices: $connectedDevices, game: $game)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SynchronizedData &&
            const DeepCollectionEquality()
                .equals(other._connectedDevices, _connectedDevices) &&
            (identical(other.game, game) || other.game == game));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_connectedDevices), game);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SynchronizedDataCopyWith<_$_SynchronizedData> get copyWith =>
      __$$_SynchronizedDataCopyWithImpl<_$_SynchronizedData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SynchronizedDataToJson(
      this,
    );
  }
}

abstract class _SynchronizedData extends SynchronizedData {
  const factory _SynchronizedData(
      {required final List<ConnectedDevice> connectedDevices,
      required final Game game}) = _$_SynchronizedData;
  const _SynchronizedData._() : super._();

  factory _SynchronizedData.fromJson(Map<String, dynamic> json) =
      _$_SynchronizedData.fromJson;

  @override
  List<ConnectedDevice> get connectedDevices;
  @override
  Game get game;
  @override
  @JsonKey(ignore: true)
  _$$_SynchronizedDataCopyWith<_$_SynchronizedData> get copyWith =>
      throw _privateConstructorUsedError;
}
