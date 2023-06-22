import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  MessageSenderNotifier({WebSocketSink? sink, Stream<dynamic>? stream}) : super(MessageSender(sink: sink, stream: stream));

  void _setSinkAndStream(WebSocketSink? sink, Stream<dynamic>? stream) {
    state = state.copyWith(sink: sink, stream: stream);
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, MessageSender>((ref) {
  const port = 6353;
  final notifier = MessageSenderNotifier();

  print('Connecting as client');
  final channel = IOWebSocketChannel.connect(
    Uri.parse('ws://192.168.8.108:$port'),
  );
  channel.stream.listen(
    (_) {},
    onError: (error) {
      print('Could not connect');
    },
  );
  // channel.ready.then((_) {
  //   print('Connected successfully');
  //   notifier._setSinkAndStream(
  //     channel.sink,
  //     channel.stream.handleError(
  //       (error) {
  //         if (error is TimeoutException || error is SocketException) {
  //           print('Could not connect');
  //         } else {
  //           // Could not handle error, so we are rethrowing it.
  //           throw error;
  //         }
  //       },
  //       test: (error) => error is TimeoutException,
  //     ),
  //   );
  // });
  ref.onDispose(channel.sink.close);

  return notifier;
});
