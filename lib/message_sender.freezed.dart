// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_sender.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MessageSender {
  Socket? get socket => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageSenderCopyWith<MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderCopyWith<$Res> {
  factory $MessageSenderCopyWith(
          MessageSender value, $Res Function(MessageSender) then) =
      _$MessageSenderCopyWithImpl<$Res, MessageSender>;
  @useResult
  $Res call({Socket? socket});
}

/// @nodoc
class _$MessageSenderCopyWithImpl<$Res, $Val extends MessageSender>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? socket = freezed,
  }) {
    return _then(_value.copyWith(
      socket: freezed == socket
          ? _value.socket
          : socket // ignore: cast_nullable_to_non_nullable
              as Socket?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MessageSenderCopyWith<$Res>
    implements $MessageSenderCopyWith<$Res> {
  factory _$$_MessageSenderCopyWith(
          _$_MessageSender value, $Res Function(_$_MessageSender) then) =
      __$$_MessageSenderCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Socket? socket});
}

/// @nodoc
class __$$_MessageSenderCopyWithImpl<$Res>
    extends _$MessageSenderCopyWithImpl<$Res, _$_MessageSender>
    implements _$$_MessageSenderCopyWith<$Res> {
  __$$_MessageSenderCopyWithImpl(
      _$_MessageSender _value, $Res Function(_$_MessageSender) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? socket = freezed,
  }) {
    return _then(_$_MessageSender(
      socket: freezed == socket
          ? _value.socket
          : socket // ignore: cast_nullable_to_non_nullable
              as Socket?,
    ));
  }
}

/// @nodoc

class _$_MessageSender extends _MessageSender {
  _$_MessageSender({this.socket}) : super._();

  @override
  final Socket? socket;

  @override
  String toString() {
    return 'MessageSender(socket: $socket)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MessageSender &&
            (identical(other.socket, socket) || other.socket == socket));
  }

  @override
  int get hashCode => Object.hash(runtimeType, socket);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MessageSenderCopyWith<_$_MessageSender> get copyWith =>
      __$$_MessageSenderCopyWithImpl<_$_MessageSender>(this, _$identity);
}

abstract class _MessageSender extends MessageSender {
  factory _MessageSender({final Socket? socket}) = _$_MessageSender;
  _MessageSender._() : super._();

  @override
  Socket? get socket;
  @override
  @JsonKey(ignore: true)
  _$$_MessageSenderCopyWith<_$_MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}
