import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({
    @protected WebSocketSink? sink,
    @protected Stream<dynamic>? stream,
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

  void subscribe(void Function(NetworkMessage) onData) {
    return;
    late final NetworkMessage parsedData;
    if (!isConnected) {
      // Should we throw instead of return? The reasoning for silently ignoring it is that whatever calls this chould be notified when we connect, and then call this function again.
      return;
    }
    stream!.listen(
      (data) {
        // Try to convert the messages recieved to NetworkMessages and forward them to the provided function if sucessfull.
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
        print('Websocket disconnected.');
      },
    );
  }
}
