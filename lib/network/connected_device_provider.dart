import 'package:darq/darq.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/network/connected_device.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/player.dart';

/// Provides the identifier of the connected device that we are.
final StateProvider<int?> connectedDeviceIdentifierProvider = StateProvider<int?>((ref) => null);

/// Provides the connected device that we are.
final Provider<ConnectedDevice?> connectedDeviceProvider = Provider<ConnectedDevice?>((ref) {
  final identifier = ref.watch(connectedDeviceIdentifierProvider);
  final devices = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.connectedDevices));

  return devices.firstWhereOrDefault((device) => device.identifier == identifier);
});

/// Provides the player we control
final controlledPlayerProvider = Provider<Player?>((ref) {
  final controlledPlayerId = ref.watch(connectedDeviceProvider.select((connectedDevice) => connectedDevice?.controlledPlayerId));
  if (controlledPlayerId == null) return null;
  final controlledPlayer = ref.watch(gameProvider)?.players.singleWhere((player) => player.configuration.id == controlledPlayerId);

  return controlledPlayer;
});
