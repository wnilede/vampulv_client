import 'dart:math';

import 'package:darq/darq.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vampulv/network/connected_device.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_bodies/change_device_controls_body.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/saved_game.dart';
import 'package:vampulv/network/synchronized_data.dart';

part 'synchronized_data_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentSynchronizedData extends _$CurrentSynchronizedData {
  @override
  SynchronizedData build() {
    final messageSender = ref.watch(currentMessageSenderProvider);
    messageSender.sendString('Change room:default');
    ref.watch(currentMessageSenderProvider.notifier).subscribe(applyChange);
    return SynchronizedData(game: SavedGame(configuration: GameConfiguration(randomSeed: Random().nextInt(1 << 32 - 1))));
  }

  void applyChange(NetworkMessage event) {
    if (!event.type.isSynchronizedDataChange) {
      return;
    }
    if (event.type.isGameChange) {
      // Should we sort them by timestamp here?
      state = state.copyWith.game(events: [
        ...state.game.events,
        event,
      ]);
      return;
    }
    switch (event.type) {
      case NetworkMessageType.setGameConfiguration:
        state = state.copyWith.game(configuration: GameConfiguration.fromJson(event.body));
        break;
      case NetworkMessageType.setDevices:
        List<int> identifiers = event.message.split(';').map((identifier) => int.parse(identifier)).toList();
        // Keep the devices with identifiers in the list, and create new devices for the identifiers without a device.
        final oldDevices = state.connectedDevices.where((device) => identifiers.contains(device.identifier)).toList();
        final newDevices = identifiers.where((identifier) => state.connectedDevices.every((device) => device.identifier != identifier)).map((identifier) => ConnectedDevice(identifier: identifier)).toList();
        state = state.copyWith(connectedDevices: [
          ...oldDevices,
          ...newDevices,
        ]);
        // If new devices have been added, we send all of the synchronized data, but to prevent multiple devices from sending, only the one with the lowest identifier that was not just added sends.
        if (newDevices.isNotEmpty && oldDevices.isNotEmpty && ref.read(connectedDeviceIdentifierProvider) == oldDevices.map((device) => device.identifier).min()) {
          ref.read(currentMessageSenderProvider).sendSynchronizedData(state);
        }
        break;
      case NetworkMessageType.changeDeviceControls:
        final body = ChangeDeviceControlsBody.fromJson(event.body);
        final List<ConnectedDevice> newConnectedDevices = [
          ...state.connectedDevices
        ];
        for (int i = 0; i < newConnectedDevices.length; i++) {
          if (newConnectedDevices[i].identifier == body.deviceToChangeId) {
            newConnectedDevices[i] = newConnectedDevices[i].copyWith(controlledPlayerId: body.playerToControlId);
          }
        }
        state = state.copyWith(connectedDevices: newConnectedDevices);
        break;
      case NetworkMessageType.setSynchronizedData:
        state = SynchronizedData.fromJson(event.body);
        break;
      default:
        throw ArgumentError.value(event.type.name);
    }
  }
}

@riverpod
GameConfiguration gameConfiguration(GameConfigurationRef ref) => //
    ref.watch(currentSynchronizedDataProvider.select((sd) => sd.game.configuration));
