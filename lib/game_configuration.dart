import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/roles/role.dart';

part 'game_configuration.freezed.dart';
part 'game_configuration.g.dart';

@freezed
class GameConfiguration with _$GameConfiguration {
  factory GameConfiguration({
    @Default([]) List<PlayerConfiguration> players,
    @Default([]) List<RoleType> roles,
    required int randomSeed,
    @Default(2) int maxLives,
    @Default(2) int rolesPerPlayer,
  }) = _GameConfiguration;

  factory GameConfiguration.fromJson(Map<String, dynamic> json) => _$GameConfigurationFromJson(json);
}
