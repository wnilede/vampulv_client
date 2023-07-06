import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_device_controls_body.freezed.dart';
part 'change_device_controls_body.g.dart';

@freezed
class ChangeDeviceControlsBody with _$ChangeDeviceControlsBody {
  factory ChangeDeviceControlsBody({
    required int deviceToChangeId,
    required int? playerToControlId,
  }) = _ChangeDeviceControlsBody;

  factory ChangeDeviceControlsBody.fromJson(Map<String, dynamic> json) => _$ChangeDeviceControlsBodyFromJson(json);
}
