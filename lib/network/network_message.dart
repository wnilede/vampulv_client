import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/network/network_message_type.dart';

part 'network_message.freezed.dart';
part 'network_message.g.dart';

@freezed
class NetworkMessage with _$NetworkMessage {
  const factory NetworkMessage({
    required NetworkMessageType type,
    required String message,
    int? timestamp,
  }) = _NetworkMessage;
  factory NetworkMessage.fromJson(Map<String, Object?> json) => _$NetworkMessageFromJson(json);
  const NetworkMessage._();

  Map<String, Object?> get body => json.decode(message);

  factory NetworkMessage.fromObject({
    required NetworkMessageType type,
    required Object body,
    int? timestamp,
  }) {
    return NetworkMessage(
      type: type,
      message: json.encode(body),
      timestamp: timestamp,
    );
  }
}
