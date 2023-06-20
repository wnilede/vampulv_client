import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/connected_device.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:vampulv/synchronized_data/network_message_type.dart';
import 'package:vampulv/synchronized_data/synchronized_data.dart';

class SynchronizedDataNotifier extends StateNotifier<SynchronizedData> {
  SynchronizedDataNotifier({List<NetworkMessage> gameEvents = const []})
      : super(SynchronizedData(
          connectedDevices: [],
          game: Game(
            users: [],
            events: gameEvents,
            started: false,
          ),
        ));

  void applyChange(NetworkMessage event) {
    if (!event.type.isSynchronizedDataChange) {
      return;
    }
    if (event.type.isGameChange) {
      state = state.copyWith(game: state.game.applyChange(event));
      return;
    }
    switch (event.type) {
      case NetworkMessageType.addDevice:
        state = state.copyWith(connectedDevices: [
          ...state.connectedDevices,
          ConnectedDevice.fromJson(json.decode(event.message)),
        ]);
        break;
      case NetworkMessageType.changeDeviceControls:
        break;
      default:
        throw ArgumentError.value(event.type);
    }
  }
}

final StateNotifierProvider<SynchronizedDataNotifier, SynchronizedData> synchronizedDataProvider = StateNotifierProvider<SynchronizedDataNotifier, SynchronizedData>((ref) {
  SynchronizedDataNotifier notifier = SynchronizedDataNotifier();

  final messageSender = ref.watch(messageSenderProvider);
  messageSender.sendChange(NetworkMessage(
    type: NetworkMessageType.addPlayer,
    message: json.encode(const Player(name: 'unnamed', position: 0)),
  ));
  messageSender.sendChange(NetworkMessage(
    type: NetworkMessageType.addDevice,
    message: json.encode(const ConnectedDevice(controls: null)),
  ));
  messageSender.channel?.stream.listen(
    (data) {
      print("Data '$data' recieved on websocket.");
      // Convert the messages recieved to NetworkMessages and apply them.
      late final NetworkMessage networkMessage;
      try {
        networkMessage = NetworkMessage.fromJson(json.decode(data as String));
      } on FormatException {
        print('Could not parse data.');
        return;
      }
      notifier.applyChange(networkMessage);
    },
    onError: (Object error, StackTrace stackTrace) {
      print('An error occured. Error object: $error. Stack trace: $stackTrace.');
    },
    onDone: () {
      print('Websocket disconnected.');
    },
  );
  return notifier;
});
