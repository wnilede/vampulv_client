import 'package:freezed_annotation/freezed_annotation.dart';

import '../game_logic/saved_game.dart';
import 'connected_device.dart';

part 'synchronized_data.freezed.dart';
part 'synchronized_data.g.dart';

// Contains the whole state of the application except current connected device, socket properties and localy stored games. Should always be synchronized between all connected devices.
@freezed
class SynchronizedData with _$SynchronizedData {
  const factory SynchronizedData({
    @Default([])
    List<ConnectedDevice>
        connectedDevices, // A list of connected devices identifiers are sent by the server whenever anyone connects or disconnect, which is how devices are added and removed. Entire devices are sent from clients to change existing devices.
    required SavedGame game, // Information needed to recreate the current game from scratch.
  }) = _SynchronizedData;

  factory SynchronizedData.fromJson(Map<String, Object?> json) => _$SynchronizedDataFromJson(json);

  const SynchronizedData._();
}
