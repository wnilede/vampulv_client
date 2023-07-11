import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/roles/vampulv.dart';

class LonelyPulv extends Vampulv {
  LonelyPulv() {
    type = RoleType.lonelyPulv;
    reactions.add(
      RoleReaction<GameEndsEvent>(
          priority: 60,
          onApply: (event, game, player) {
            if (player.isWinner && game.players.any((otherPlayer) => otherPlayer.alive && otherPlayer.configuration.id != player.configuration.id)) {
              return player.copyWith(isWinner: false);
            }
          }),
    );
  }
}
