import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/connected_device.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/synchronized_data/network_message.dart';

part 'synchronized_data.freezed.dart';
part 'synchronized_data.g.dart';

// Contains the whole state of the application except current connected device and socket properties. Should always be synchronized between all connected devices.
@freezed
class SynchronizedData with _$SynchronizedData {
  const factory SynchronizedData({
    @Default([]) List<ConnectedDevice> connectedDevices, // A list of connected devices identifiers are sent by the server whenever anyone connects or disconnect, which is how devices are added and removed. Entire devices are sent from clients to change existing devices.
    required GameConfiguration gameConfiguration, // Are sent as a whole by clients.
    @Default([]) List<NetworkMessage> gameEvents, // Are sent one event at a time.
    @Default(false) bool gameHasBegun, // Are only sent as a part of a whole SynchronizedData object.
  }) = _SynchronizedData;

  factory SynchronizedData.fromJson(Map<String, Object?> json) => _$SynchronizedDataFromJson(json);

  const SynchronizedData._();
}
