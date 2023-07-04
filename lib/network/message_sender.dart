import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({
    WebSocketSink? sink,
    Stream<dynamic>? stream,
  }) = _MessageSender;
  const MessageSender._();

  bool get isConnected => sink != null && stream != null;

  void sendChange(NetworkMessage event) {
    if (event.timestamp == null) {
      event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
    }
    sendString(json.encode(event.toJson()));
  }

  void sendString(String message) {
    if (sink != null) {
      sink!.add(message);
    }
  }
}
