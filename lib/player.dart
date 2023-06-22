import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/role.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required PlayerConfiguration configuration,
    required List<Role> roles,
    required int lives,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}
