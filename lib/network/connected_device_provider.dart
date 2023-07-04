import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

// Provides the identifier of the connected device that we are.
final StateProvider<int?> connectedDeviceIdentifierProvider = StateProvider<int?>((ref) => null);

// Provides the connected device that we are.
final Provider<ConnectedDevice?> connectedDeviceProvider = Provider<ConnectedDevice?>((ref) {
  final identifier = ref.watch(connectedDeviceIdentifierProvider);
  final devices = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.connectedDevices));

  if (devices.any((device) => device.identifier == identifier)) {
    return null;
  } else {
    return devices.firstWhere((device) => device.identifier == identifier);
  }
});
