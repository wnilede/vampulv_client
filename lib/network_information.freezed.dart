// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_information.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$NetworkInformation {
  int get hej => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NetworkInformationCopyWith<NetworkInformation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkInformationCopyWith<$Res> {
  factory $NetworkInformationCopyWith(
          NetworkInformation value, $Res Function(NetworkInformation) then) =
      _$NetworkInformationCopyWithImpl<$Res, NetworkInformation>;
  @useResult
  $Res call({int hej});
}

/// @nodoc
class _$NetworkInformationCopyWithImpl<$Res, $Val extends NetworkInformation>
    implements $NetworkInformationCopyWith<$Res> {
  _$NetworkInformationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hej = null,
  }) {
    return _then(_value.copyWith(
      hej: null == hej
          ? _value.hej
          : hej // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_NetworkInformationCopyWith<$Res>
    implements $NetworkInformationCopyWith<$Res> {
  factory _$$_NetworkInformationCopyWith(_$_NetworkInformation value,
          $Res Function(_$_NetworkInformation) then) =
      __$$_NetworkInformationCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hej});
}

/// @nodoc
class __$$_NetworkInformationCopyWithImpl<$Res>
    extends _$NetworkInformationCopyWithImpl<$Res, _$_NetworkInformation>
    implements _$$_NetworkInformationCopyWith<$Res> {
  __$$_NetworkInformationCopyWithImpl(
      _$_NetworkInformation _value, $Res Function(_$_NetworkInformation) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hej = null,
  }) {
    return _then(_$_NetworkInformation(
      null == hej
          ? _value.hej
          : hej // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_NetworkInformation implements _NetworkInformation {
  const _$_NetworkInformation(this.hej);

  @override
  final int hej;

  @override
  String toString() {
    return 'NetworkInformation(hej: $hej)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_NetworkInformation &&
            (identical(other.hej, hej) || other.hej == hej));
  }

  @override
  int get hashCode => Object.hash(runtimeType, hej);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_NetworkInformationCopyWith<_$_NetworkInformation> get copyWith =>
      __$$_NetworkInformationCopyWithImpl<_$_NetworkInformation>(
          this, _$identity);
}

abstract class _NetworkInformation implements NetworkInformation {
  const factory _NetworkInformation(final int hej) = _$_NetworkInformation;

  @override
  int get hej;
  @override
  @JsonKey(ignore: true)
  _$$_NetworkInformationCopyWith<_$_NetworkInformation> get copyWith =>
      throw _privateConstructorUsedError;
}
