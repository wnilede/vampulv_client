import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_sender.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSenderNotifier extends StateNotifier<MessageSender> {
  final Ref ref;

  MessageSenderNotifier(this.ref, {WebSocketSink? sink, Stream<dynamic>? stream}) : super(MessageSender(sink: sink, stream: stream));

  void _setSinkAndStream(WebSocketSink? sink, Stream<dynamic>? stream) {
    state = state.copyWith(sink: sink, stream: stream);
  }

  void subscribe(void Function(NetworkMessage) onData) {
    if (!state.isConnected) {
      // Should we throw instead of return? The reasoning for silently ignoring it is that whatever calls this should be notified when we connect, and then call this function again.
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
        if (parsedData.type == NetworkMessageType.setIdentifier) {
          // This is ugly and the logic should not be here, but the one listening is SynchronizedData which should have this logic even less. Should be changed.
          ref.read(connectedDeviceIdentifierProvider.notifier).state = int.parse(parsedData.message);
          return;
        }
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
  final notifier = MessageSenderNotifier(ref);

  print('Connecting as client');
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.8.111:$port'),
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