import 'package:freezed_annotation/freezed_annotation.dart';

part 'changedevicecontrolsbody.freezed.dart';
part 'changedevicecontrolsbody.g.dart';

@freezed
class ChangeDeviceControlsBody with _$ChangeDeviceControlsBody {
  factory ChangeDeviceControlsBody({
    required int deviceToChangeId,
    required int playerToControlId,
  }) = _ChangeDeviceControlsBody;

  factory ChangeDeviceControlsBody.fromJson(Map<String, dynamic> json) => _$ChangeDeviceControlsBodyFromJson(json);
}
