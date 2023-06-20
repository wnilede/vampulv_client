// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

NetworkMessage _$NetworkMessageFromJson(Map<String, dynamic> json) {
  return _NetworkMessage.fromJson(json);
}

/// @nodoc
mixin _$NetworkMessage {
  MessageType get messageType => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NetworkMessageCopyWith<NetworkMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkMessageCopyWith<$Res> {
  factory $NetworkMessageCopyWith(
          NetworkMessage value, $Res Function(NetworkMessage) then) =
      _$NetworkMessageCopyWithImpl<$Res, NetworkMessage>;
  @useResult
  $Res call({MessageType messageType, String body});
}

/// @nodoc
class _$NetworkMessageCopyWithImpl<$Res, $Val extends NetworkMessage>
    implements $NetworkMessageCopyWith<$Res> {
  _$NetworkMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageType = null,
    Object? body = null,
  }) {
    return _then(_value.copyWith(
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as MessageType,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_NetworkMessageCopyWith<$Res>
    implements $NetworkMessageCopyWith<$Res> {
  factory _$$_NetworkMessageCopyWith(
          _$_NetworkMessage value, $Res Function(_$_NetworkMessage) then) =
      __$$_NetworkMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MessageType messageType, String body});
}

/// @nodoc
class __$$_NetworkMessageCopyWithImpl<$Res>
    extends _$NetworkMessageCopyWithImpl<$Res, _$_NetworkMessage>
    implements _$$_NetworkMessageCopyWith<$Res> {
  __$$_NetworkMessageCopyWithImpl(
      _$_NetworkMessage _value, $Res Function(_$_NetworkMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageType = null,
    Object? body = null,
  }) {
    return _then(_$_NetworkMessage(
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as MessageType,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_NetworkMessage implements _NetworkMessage {
  const _$_NetworkMessage({required this.messageType, required this.body});

  factory _$_NetworkMessage.fromJson(Map<String, dynamic> json) =>
      _$$_NetworkMessageFromJson(json);

  @override
  final MessageType messageType;
  @override
  final String body;

  @override
  String toString() {
    return 'NetworkMessage(messageType: $messageType, body: $body)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_NetworkMessage &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, messageType, body);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_NetworkMessageCopyWith<_$_NetworkMessage> get copyWith =>
      __$$_NetworkMessageCopyWithImpl<_$_NetworkMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_NetworkMessageToJson(
      this,
    );
  }
}

abstract class _NetworkMessage implements NetworkMessage {
  const factory _NetworkMessage(
      {required final MessageType messageType,
      required final String body}) = _$_NetworkMessage;

  factory _NetworkMessage.fromJson(Map<String, dynamic> json) =
      _$_NetworkMessage.fromJson;

  @override
  MessageType get messageType;
  @override
  String get body;
  @override
  @JsonKey(ignore: true)
  _$$_NetworkMessageCopyWith<_$_NetworkMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
