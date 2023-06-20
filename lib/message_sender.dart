import 'dart:convert';
import 'dart:html';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/synchronized_data/network_message.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({WebSocket? socket}) = _MessageSender;
  const MessageSender._();

  void sendChange(NetworkMessage event) {
    if (socket != null) {
      if (event.timestamp == null) {
        event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
      }
      socket!.sink.add(json.encode(event.toJson()));
    }
  }
}
