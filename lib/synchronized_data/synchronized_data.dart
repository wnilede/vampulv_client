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
    @Default([]) List<ConnectedDevice> connectedDevices,
    required GameConfiguration gameConfiguration,
    @Default([]) List<NetworkMessage> gameEvents,
    @Default(false) bool gameHasBegun,
  }) = _SynchronizedData;

  factory SynchronizedData.fromJson(Map<String, Object?> json) => _$SynchronizedDataFromJson(json);

  const SynchronizedData._();
}
