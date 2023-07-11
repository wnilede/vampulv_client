import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/vampulv.dart';

class LonelyPulv extends Vampulv {
  LonelyPulv() {
    type = RoleType.lonelyPulv;
    reactions.add(
      RoleReaction(
          priority: 60,
          filter: EventType.gameEnds,
          applyer: (event, game, player) {
            if (player.isWinner && game.players.any((otherPlayer) => otherPlayer.alive && otherPlayer.configuration.id != player.configuration.id)) {
              return player.copyWith(isWinner: false);
            }
          }),
    );
  }
}
