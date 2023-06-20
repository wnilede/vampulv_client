// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'synchronized_data_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SynchronizedDataChange _$$_SynchronizedDataChangeFromJson(
        Map<String, dynamic> json) =>
    _$_SynchronizedDataChange(
      type: $enumDecode(_$SynchronizedDataChangeTypeEnumMap, json['type']),
      message: json['message'] as String,
      timestamp: json['timestamp'] as int?,
    );

Map<String, dynamic> _$$_SynchronizedDataChangeToJson(
        _$_SynchronizedDataChange instance) =>
    <String, dynamic>{
      'type': _$SynchronizedDataChangeTypeEnumMap[instance.type]!,
      'message': instance.message,
      'timestamp': instance.timestamp,
    };

const _$SynchronizedDataChangeTypeEnumMap = {
  SynchronizedDataChangeType.addPlayer: 'addPlayer',
  SynchronizedDataChangeType.addDevice: 'addDevice',
  SynchronizedDataChangeType.changeDeviceControls: 'changeDeviceControls',
};
