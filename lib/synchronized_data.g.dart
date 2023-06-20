// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'synchronized_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SynchronizedData _$$_SynchronizedDataFromJson(Map<String, dynamic> json) =>
    _$_SynchronizedData(
      connectedDevices: (json['connectedDevices'] as List<dynamic>)
          .map((e) => ConnectedDevice.fromJson(e as Map<String, dynamic>))
          .toList(),
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_SynchronizedDataToJson(_$_SynchronizedData instance) =>
    <String, dynamic>{
      'connectedDevices': instance.connectedDevices,
      'game': instance.game,
    };
