// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_NetworkMessage _$$_NetworkMessageFromJson(Map<String, dynamic> json) =>
    _$_NetworkMessage(
      messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
      body: json['body'] as String,
    );

Map<String, dynamic> _$$_NetworkMessageToJson(_$_NetworkMessage instance) =>
    <String, dynamic>{
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'body': instance.body,
    };

const _$MessageTypeEnumMap = {
  MessageType.entireGame: 'entireGame',
  MessageType.userInput: 'userInput',
};
