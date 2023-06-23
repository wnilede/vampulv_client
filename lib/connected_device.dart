import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/player.dart';

part 'connected_device.freezed.dart';
part 'connected_device.g.dart';

@freezed
class ConnectedDevice with _$ConnectedDevice {
  const factory ConnectedDevice({
    Player? controls,
    required int identifier,
  }) = _ConnectedDevice;
  factory ConnectedDevice.fromJson(Map<String, Object?> json) => _$ConnectedDeviceFromJson(json);
}
