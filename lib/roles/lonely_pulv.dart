import 'package:darq/darq.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import 'vampulv.dart';

class LonelyPulv extends Vampulv {
  LonelyPulv() {
    type = RoleType.lonelyPulv;
    reactions.add(
      RoleReaction<GameEndsEvent>(
          priority: 60,
          worksAfterDeath: true,
          onApply: (event, game, player) {
            if (player.isWinner && (!player.alive || game.alivePlayers.any((otherPlayer) => otherPlayer.id != player.id))) {
              return player.copyWith(isWinner: false);
            }
          }),
    );
    // If there are no ordinary vampulvs, no VampulvRule is created by normal means. This reaction is to create one in that case.
    reactions.add(
      RoleReaction<GameBeginsEvent>(
          priority: 200,
          worksAfterDeath: true,
          onApply: (event, game, player) {
            if (game.rules.any((rule) => rule is VampulvRule)) {
              return game.copyWith(rules: game.rules.append(VampulvRule()).toList());
            }
          }),
    );
  }
}
