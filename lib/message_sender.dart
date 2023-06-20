import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/synchronized_data_change.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({Socket? socket}) = _MessageSender;
  const MessageSender._();

  void sendChange(SynchronizedDataChange event) {
    if (socket != null) {
      if (event.timestamp == null) {
        event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
      }
      socket!.write(json.encode(event.toJson()));
    }
  }
}

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  MessageSenderNotifier() : super(MessageSender());

  set socket(Socket socket) {
    state = state.copyWith(socket: socket);
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, MessageSender>((ref) => MessageSenderNotifier());
