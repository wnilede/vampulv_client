import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_settings.freezed.dart';
part 'connection_settings.g.dart';

@freezed
class ConnectionSettings with _$ConnectionSettings {
  factory ConnectionSettings({
    required String adress,
    required String room,
  }) = _ConnectionSettings;

  factory ConnectionSettings.fromJson(Map<String, dynamic> json) => _$ConnectionSettingsFromJson(json);
}

@Riverpod(keepAlive: true)
class CConnectionSettings extends _$CConnectionSettings {
  @override
  ConnectionSettings build() => ConnectionSettings(adress: 'ws://192.168.8.119:6353', room: 'default');

  void setState(ConnectionSettings value) {
    state = value;
  }
}
