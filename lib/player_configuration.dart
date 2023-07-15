import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_configuration.freezed.dart';
part 'player_configuration.g.dart';

@freezed
class PlayerConfiguration with _$PlayerConfiguration {
  factory PlayerConfiguration({
    required int id,
    required String name,
  }) = _PlayerConfiguration;

  factory PlayerConfiguration.fromJson(Map<String, dynamic> json) => _$PlayerConfigurationFromJson(json);

  const PlayerConfiguration._();

  String get namePlural => name.trimRight().endsWith('s') ? name : '${name}s';
}
