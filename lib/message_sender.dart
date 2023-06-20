import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({WebSocketChannel? channel}) = _MessageSender;
  const MessageSender._();

  void sendChange(NetworkMessage event) {
    if (channel != null) {
      if (event.timestamp == null) {
        event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
      }
      channel!.sink.add(json.encode(event.toJson()));
    }
  }
}
