import 'dart:html';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender.dart';

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  MessageSenderNotifier(WebSocket? socket) : super(MessageSender(socket: socket));

  set socket(WebSocket socket) {
    state = state.copyWith(socket: socket);
  }

  void listen() {
    state.socket.
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, MessageSender>((ref) {
  const port = 6353;

  print('Connecting as client');
  final socket = WebSocket('ws://localhost:$port');
  ref.onDispose(socket.close);
  print('Connected successfully');

  return MessageSenderNotifier(socket);
});
