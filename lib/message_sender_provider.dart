import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  MessageSenderNotifier(WebSocketChannel? channel) : super(MessageSender(channel: channel));

  set channel(WebSocketChannel channel) {
    state = state.copyWith(channel: channel);
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, MessageSender>((ref) {
  const port = 6353;

  print('Connecting as client');
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.8.122:$port'),
  );
  ref.onDispose(channel.sink.close);
  print('Connected successfully');

  return MessageSenderNotifier(channel);
});
