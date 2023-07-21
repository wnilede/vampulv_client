import 'package:darq/darq.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vampulv/game_logic/game_provider.dart';
import 'package:vampulv/network/connected_device.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/game_logic/player.dart';

part 'connected_device_provider.g.dart';

/// Provides the identifier of the connected device that we are.
@Riverpod(keepAlive: true)
class ConnectedDeviceIdentifier extends _$ConnectedDeviceIdentifier {
  @override
  int? build() => null;

  void setValue(int? value) {
    state = value;
  }
}

/// Provides the connected device that we are.
@riverpod
ConnectedDevice? connectedDevice(ConnectedDeviceRef ref) {
  final identifier = ref.watch(connectedDeviceIdentifierProvider);
  final devices = ref.watch(cSynchronizedDataProvider.select((synchronizedData) => synchronizedData.connectedDevices));

  return devices.firstWhereOrDefault((device) => device.identifier == identifier);
}

/// Provides the player we control
@riverpod
Player? controlledPlayer(ControlledPlayerRef ref) {
  final controlledPlayerId = ref.watch(connectedDeviceProvider.select((connectedDevice) => connectedDevice?.controlledPlayerId));
  if (controlledPlayerId == null) return null;
  final controlledPlayer = ref.watch(cGameProvider)?.players.singleWhere((player) => player.id == controlledPlayerId);

  return controlledPlayer;
}
