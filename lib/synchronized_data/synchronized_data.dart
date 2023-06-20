import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/connected_device.dart';
import 'package:vampulv/game.dart';

part 'synchronized_data.freezed.dart';
part 'synchronized_data.g.dart';

// Contains the whole state of the application except current connected device and socket properties. Should always be synchronized between all connected devices.
@freezed
class SynchronizedData with _$SynchronizedData {
  const factory SynchronizedData({
    required List<ConnectedDevice> connectedDevices,
    required Game game,
  }) = _SynchronizedData;

  factory SynchronizedData.fromJson(Map<String, Object?> json) => _$SynchronizedDataFromJson(json);

  const SynchronizedData._();
}
