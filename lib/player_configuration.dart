import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_configuration.freezed.dart';
part 'player_configuration.g.dart';

@freezed
class PlayerConfiguration with _$PlayerConfiguration {
  factory PlayerConfiguration({
    required int id,
    required String name,
    required int position,
  }) = _PlayerConfiguration;

  factory PlayerConfiguration.fromJson(Map<String, dynamic> json) => _$PlayerConfigurationFromJson(json);
}
