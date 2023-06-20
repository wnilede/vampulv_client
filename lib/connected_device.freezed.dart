// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connected_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ConnectedDevice _$ConnectedDeviceFromJson(Map<String, dynamic> json) {
  return _ConnectedDevice.fromJson(json);
}

/// @nodoc
mixin _$ConnectedDevice {
  Player? get controls => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConnectedDeviceCopyWith<ConnectedDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectedDeviceCopyWith<$Res> {
  factory $ConnectedDeviceCopyWith(
          ConnectedDevice value, $Res Function(ConnectedDevice) then) =
      _$ConnectedDeviceCopyWithImpl<$Res, ConnectedDevice>;
  @useResult
  $Res call({Player? controls});

  $PlayerCopyWith<$Res>? get controls;
}

/// @nodoc
class _$ConnectedDeviceCopyWithImpl<$Res, $Val extends ConnectedDevice>
    implements $ConnectedDeviceCopyWith<$Res> {
  _$ConnectedDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controls = freezed,
  }) {
    return _then(_value.copyWith(
      controls: freezed == controls
          ? _value.controls
          : controls // ignore: cast_nullable_to_non_nullable
              as Player?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PlayerCopyWith<$Res>? get controls {
    if (_value.controls == null) {
      return null;
    }

    return $PlayerCopyWith<$Res>(_value.controls!, (value) {
      return _then(_value.copyWith(controls: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_ConnectedDeviceCopyWith<$Res>
    implements $ConnectedDeviceCopyWith<$Res> {
  factory _$$_ConnectedDeviceCopyWith(
          _$_ConnectedDevice value, $Res Function(_$_ConnectedDevice) then) =
      __$$_ConnectedDeviceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Player? controls});

  @override
  $PlayerCopyWith<$Res>? get controls;
}

/// @nodoc
class __$$_ConnectedDeviceCopyWithImpl<$Res>
    extends _$ConnectedDeviceCopyWithImpl<$Res, _$_ConnectedDevice>
    implements _$$_ConnectedDeviceCopyWith<$Res> {
  __$$_ConnectedDeviceCopyWithImpl(
      _$_ConnectedDevice _value, $Res Function(_$_ConnectedDevice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controls = freezed,
  }) {
    return _then(_$_ConnectedDevice(
      controls: freezed == controls
          ? _value.controls
          : controls // ignore: cast_nullable_to_non_nullable
              as Player?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ConnectedDevice implements _ConnectedDevice {
  const _$_ConnectedDevice({required this.controls});

  factory _$_ConnectedDevice.fromJson(Map<String, dynamic> json) =>
      _$$_ConnectedDeviceFromJson(json);

  @override
  final Player? controls;

  @override
  String toString() {
    return 'ConnectedDevice(controls: $controls)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ConnectedDevice &&
            (identical(other.controls, controls) ||
                other.controls == controls));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, controls);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ConnectedDeviceCopyWith<_$_ConnectedDevice> get copyWith =>
      __$$_ConnectedDeviceCopyWithImpl<_$_ConnectedDevice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ConnectedDeviceToJson(
      this,
    );
  }
}

abstract class _ConnectedDevice implements ConnectedDevice {
  const factory _ConnectedDevice({required final Player? controls}) =
      _$_ConnectedDevice;

  factory _ConnectedDevice.fromJson(Map<String, dynamic> json) =
      _$_ConnectedDevice.fromJson;

  @override
  Player? get controls;
  @override
  @JsonKey(ignore: true)
  _$$_ConnectedDeviceCopyWith<_$_ConnectedDevice> get copyWith =>
      throw _privateConstructorUsedError;
}
