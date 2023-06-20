// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connected_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ConnectedDevice _$$_ConnectedDeviceFromJson(Map<String, dynamic> json) =>
    _$_ConnectedDevice(
      controls: json['controls'] == null
          ? null
          : Player.fromJson(json['controls'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_ConnectedDeviceToJson(_$_ConnectedDevice instance) =>
    <String, dynamic>{
      'controls': instance.controls,
    };
