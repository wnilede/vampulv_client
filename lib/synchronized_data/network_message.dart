import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/synchronized_data/network_message_type.dart';

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
}
