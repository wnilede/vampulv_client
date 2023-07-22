import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connected_device_provider.dart';
import 'connection_settings.dart';
import 'message_sender.dart';
import 'network_message.dart';
import 'network_message_type.dart';
import 'synchronized_data_provider.dart';

part 'message_sender_provider.g.dart';

@Riverpod(keepAlive: true)
class CMessageSender extends _$CMessageSender {
  @override
  MessageSender build() {
    ref.listen(
      cConnectionSettingsProvider,
      (previous, next) {
        // Do not need to reconnect if the only thing that changed was the room
        if (previous?.adress == next.adress) {
          state.sendString('Change room:${next.room}');
          return;
        }

        // Close the current connection if any before creating a new one
        state.sink?.close(1000);

        // Reconnect with the new settings
        state = MessageSender.loading(ref);
        _connectWithSettings(next);
      },
    );

    _connectWithSettings(ref.read(cConnectionSettingsProvider));
    return MessageSender.loading(ref);
  }

  void _connectWithSettings(ConnectionSettings settings) {
    // Create a new connection with the new address
    print('Connecting as client');
    final channel = WebSocketChannel.connect(Uri.parse(settings.adress));
    channel.ready.then((_) {
      print('Connected successfully');
      channel.stream.listen(
        (data) {
          // Try to convert the messages recieved to NetworkMessages and forward them to where they are needed
          late final NetworkMessage parsedData;
          try {
            parsedData = NetworkMessage.fromJson(json.decode(data));
          } on FormatException {
            print("Data '$data' could not be parsed.");
            return;
          }
          print("Data '$data' recieved and parsed sucessfully.");
          if (parsedData.type == NetworkMessageType.setIdentifier) {
            ref.read(connectedDeviceIdentifierProvider.notifier).setValue(int.parse(parsedData.message));
          } else if (parsedData.type.isSynchronizedDataChange) {
            ref.read(cSynchronizedDataProvider.notifier).applyChange(parsedData);
          } else {
            print("Did not know where to forward data '$data' so it is ignored.");
          }
        },
        onError: _handleErrorFromStream,
        onDone: () {
          print('Websocket disconnected.');
          state = MessageSender.error('Förlorade anslutningen till servern.', ref);
        },
      );
      state = MessageSender.connected(channel.sink, ref);
      state.sendString('Change room:${settings.room}');
    }).catchError((error, stackTrace) {
      _handleErrorFromStream(error, stackTrace);
      return null;
    });
    ref.onDispose(() => channel.sink.close(1000));
  }

  void _handleErrorFromStream(Object error, StackTrace stackTrace) {
    if (error is TimeoutException) {
      print('Could not connect: timeout');
      state = MessageSender.error('Servern tog för lång tid på sig att svara.', ref);
    } else if (error is SocketException) {
      print('Could not connect: ${error.message}');
      state = MessageSender.error('Kunde inte ansluta till servern.', ref);
    } else {
      // We do not know what kind of error it is, so we are rethrowing it
      print('An unhandled error occured in the websocket stream. Error object: $error. Stack trace: $stackTrace.');
      throw error;
    }
  }
}
