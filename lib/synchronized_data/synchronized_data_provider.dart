import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/connected_device.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:vampulv/synchronized_data/network_message_type.dart';
import 'package:vampulv/synchronized_data/synchronized_data.dart';

class SynchronizedDataNotifier extends StateNotifier<SynchronizedData> {
  SynchronizedDataNotifier({List<NetworkMessage> gameEvents = const []})
      : super(SynchronizedData(
          gameConfiguration: GameConfiguration(randomSeed: Random().nextInt(1 << 32)),
        ));

  void applyChange(NetworkMessage event) {
    if (!event.type.isSynchronizedDataChange) {
      return;
    }
    if (event.type.isGameChange) {
      // Should we sort them by timestamp here?
      state = state.copyWith(gameEvents: [
        ...state.gameEvents,
        event,
      ]);
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
    message: json.encode(PlayerConfiguration(name: 'unnamed', position: 0)),
  ));
  messageSender.sendChange(NetworkMessage(
    type: NetworkMessageType.addDevice,
    message: json.encode(const ConnectedDevice(controls: null)),
  ));
  messageSender.subscribe(notifier.applyChange);
  return notifier;
});
