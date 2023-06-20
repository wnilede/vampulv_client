import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/connected_device.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/synchronized_data_change.dart';
import 'package:vampulv/network_message.dart';

import 'message_sender.dart';

part 'synchronized_data.freezed.dart';
part 'synchronized_data.g.dart';

// Contains the whole state of the application except current connected device and socket properties. Should always be synchronized between all connected devices.
@freezed
class SynchronizedData with _$SynchronizedData {
  const factory SynchronizedData({
    required List<ConnectedDevice> connectedDevices,
    required Game game,
  }) = _SynchronizedData;

  factory SynchronizedData.fromJson(Map<String, Object?> json) => _$SynchronizedDataFromJson(json);

  const SynchronizedData._();
}

class SynchronizedDataNotifier extends StateNotifier<SynchronizedData> {
  SynchronizedDataNotifier({List<SynchronizedDataChange> gameEvents = const []})
      : super(SynchronizedData(
          connectedDevices: [],
          game: Game(
            users: [],
            events: gameEvents,
            started: false,
          ),
        ));

  void applyChange(SynchronizedDataChange event) {
    if (event.type.changesGame) {
      state = state.copyWith(game: state.game.applyChange(event));
      return;
    }
    switch (event.type) {
      case SynchronizedDataChangeType.addDevice:
        state = state.copyWith(connectedDevices: [
          ...state.connectedDevices,
          ConnectedDevice.fromJson(json.decode(event.message)),
        ]);
        break;
      case SynchronizedDataChangeType.changeDeviceControls:
        break;
      default:
        throw ArgumentError.value(event.type);
    }
  }
}

final StateNotifierProvider<SynchronizedDataNotifier, SynchronizedData> synchronizedDataProvider = StateNotifierProvider<SynchronizedDataNotifier, SynchronizedData>((ref) {
  const port = 6353;
  SynchronizedDataNotifier notifier = SynchronizedDataNotifier();

  void whenSocketConnected(final Socket socket) {
    print('Connection as client successfull');
    ref.onDispose(socket.close);
    ref.watch(messageSenderProvider.notifier).socket = socket;
    final messageSender = ref.watch(messageSenderProvider);
    messageSender.sendChange(SynchronizedDataChange(
      type: SynchronizedDataChangeType.addPlayer,
      message: json.encode(const Player(name: 'unnamed', position: 0)),
    ));
    messageSender.sendChange(SynchronizedDataChange(
      type: SynchronizedDataChangeType.addDevice,
      message: json.encode(const ConnectedDevice(controls: null)),
    ));

    // Convert the messages recieved to NetworkMessages and apply them.
    socket.listen((message) {
      notifier.applyChange(SynchronizedDataChange.fromJson(json.decode(utf8.decode(message))));
    });
  }

  print('Connecting as client');
  Socket.connect('localhost', port, timeout: Duration(seconds: 30 + Random().nextInt(30))).then(whenSocketConnected).catchError(
    test: (error) => error is SocketException,
    (error) {
      // We did not manage to connect as a client. Retry as a server.
      print('Connecting as server');
      ServerSocket.bind(InternetAddress.anyIPv4, port).then((final socket) {
        ref.onDispose(socket.close);

        List<Socket> clients = [];
        socket.listen((final client) {
          client.write(NetworkMessage(
            messageType: MessageType.entireGame,
            body: json.encode(ref.read(synchronizedDataProvider)),
          ));
          clients.add(client);
          client.listen((message) {
            // Forward the message to every client (including ourselves and the one that sent it).
            for (final clientToForwardTo in clients) {
              clientToForwardTo.write(message);
            }
          });
        });

        // We create a client socket even if we are a server, so that we can send and recieve data in the same way as other devices.
        print('Connecting as client after connecting as server');
        Socket.connect('localhost', port).then(whenSocketConnected);
      });
    },
  );
  return notifier;
});
