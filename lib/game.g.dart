// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Game _$$_GameFromJson(Map<String, dynamic> json) => _$_Game(
      users: (json['users'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map(
              (e) => SynchronizedDataChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      started: json['started'] as bool,
    );

Map<String, dynamic> _$$_GameToJson(_$_Game instance) => <String, dynamic>{
      'users': instance.users,
      'events': instance.events,
      'started': instance.started,
    };
