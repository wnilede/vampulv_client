import 'package:freezed_annotation/freezed_annotation.dart';

part 'connected_device.freezed.dart';
part 'connected_device.g.dart';

@freezed
class ConnectedDevice with _$ConnectedDevice {
  const factory ConnectedDevice({
    int? controlledPlayerId,
    required int identifier,
  }) = _ConnectedDevice;

  factory ConnectedDevice.fromJson(Map<String, Object?> json) => _$ConnectedDeviceFromJson(json);
}
