import 'dart:math';

import 'package:darq/darq.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../game_logic/game_configuration.dart';
import '../game_logic/saved_game.dart';
import '../utility/summarize_difference_jsons.dart';
import 'connected_device.dart';
import 'connected_device_provider.dart';
import 'message_bodies/change_device_controls_body.dart';
import 'message_sender_provider.dart';
import 'network_message.dart';
import 'network_message_type.dart';
import 'synchronized_data.dart';

part 'synchronized_data_provider.g.dart';

@Riverpod(keepAlive: true)
class CSynchronizedData extends _$CSynchronizedData {
  @override
  SynchronizedData build() {
    return SynchronizedData(game: SavedGame(configuration: GameConfiguration(randomSeed: Random().nextInt(1 << 32 - 1))));
  }

  void applyChange(NetworkMessage event) {
    if (!event.type.isSynchronizedDataChange) {
      return;
    }
    final stateBefore = state;
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
        final newDevices = identifiers
            .where((identifier) => state.connectedDevices.every((device) => device.identifier != identifier))
            .map((identifier) => ConnectedDevice(identifier: identifier))
            .toList();
        state = state.copyWith(connectedDevices: [
          ...oldDevices,
          ...newDevices,
        ]);
        // If new devices have been added, we send all of the synchronized data, but to prevent multiple devices from sending, only the one with the lowest identifier that was not just added sends.
        if (newDevices.isNotEmpty &&
            oldDevices.isNotEmpty &&
            ref.read(connectedDeviceIdentifierProvider) == oldDevices.map((device) => device.identifier).min()) {
          ref.read(cMessageSenderProvider).sendSynchronizedData(state);
        }
        break;
      case NetworkMessageType.changeDeviceControls:
        final body = ChangeDeviceControlsBody.fromJson(event.body);
        final List<ConnectedDevice> newConnectedDevices = [...state.connectedDevices];
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
    Logger('SynchronizedData')
        .fine(() => 'Network message of type ${event.type} handled. Diff in synchronized data:\n${summaryObjectDiff(stateBefore, state)}');
  }
}

@riverpod
GameConfiguration gameConfiguration(GameConfigurationRef ref) => ref.watch(cSynchronizedDataProvider.select((sd) => sd.game.configuration));
