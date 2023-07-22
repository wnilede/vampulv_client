import 'package:freezed_annotation/freezed_annotation.dart';
import 'player_configuration.dart';
import 'role_type.dart';

part 'game_configuration.freezed.dart';
part 'game_configuration.g.dart';

@freezed
class GameConfiguration with _$GameConfiguration {
  factory GameConfiguration({
    @Default([]) List<PlayerConfiguration> players,
    @Default([]) List<RoleType> ordinaryRoles,
    @Default([]) List<RoleType> forcedRoles,
    required int randomSeed,
    @Default(2) int maxLives,
    @Default(2) int rolesPerPlayer,
  }) = _GameConfiguration;
  GameConfiguration._();
  factory GameConfiguration.fromJson(Map<String, dynamic> json) => _$GameConfigurationFromJson(json);

  List<String> get problems {
    final result = <String>[];
    if (forcedRoles.length + ordinaryRoles.length < players.length * rolesPerPlayer) {
      result.add('Det finns inte nog med roller till alla spelare.');
    }
    if (forcedRoles.length > players.length * rolesPerPlayer) {
      result.add('Det finns inte nog med spelare för att kunna ha med alla tvingade roller.');
    }
    if (players.length < 3) {
      result.add('Det måste vara med minst 3 spelare.');
    }
    return result;
  }
}
