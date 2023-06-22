import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  MessageSenderNotifier({WebSocketSink? sink, Stream<dynamic>? stream}) : super(MessageSender(sink: sink, stream: stream));

  void _setSinkAndStream(WebSocketSink? sink, Stream<dynamic>? stream) {
    state = state.copyWith(sink: sink, stream: stream);
  }

  void subscribe(void Function(NetworkMessage) onData) {
    if (!state.isConnected) {
      // Should we throw instead of return? The reasoning for silently ignoring it is that whatever calls this chould be notified when we connect, and then call this function again.
      return;
    }
    state.stream!.listen(
      (data) {
        // Try to convert the messages recieved to NetworkMessages and forward them to the provided function if sucessfull.
        late final NetworkMessage parsedData;
        try {
          parsedData = NetworkMessage.fromJson(json.decode(data));
        } on FormatException {
          print("Data '$data' could not be parsed.");
          return;
        }
        print("Data '$data' recieved and parsed sucessfully.");
        onData(parsedData);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (error is TimeoutException || error is SocketException) {
          print('Could not connect');
        } else {
          // Could not handle error, so we are rethrowing it.
          throw error;
        }
        print('An unhandled error occured in the websocket stream. Error object: $error. Stack trace: $stackTrace.');
      },
      onDone: () {
        _setSinkAndStream(null, null);
        print('Websocket disconnected.');
      },
    );
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, MessageSender>((ref) {
  const port = 6353;
  final notifier = MessageSenderNotifier();

  print('Connecting as client');
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.8.108:$port'),
  );
  channel.ready.asStream().handleError((error, stackTrace) {
    if (error is TimeoutException || error is SocketException) {
      print('Could not connect');
    } else {
      // Could not handle error, so we are rethrowing it.
      throw error!;
    }
  }).listen((_) {
    print('Connected successfully');
    notifier._setSinkAndStream(
      channel.sink,
      channel.stream,
    );
  });
  ref.onDispose(channel.sink.close);

  return notifier;
});
