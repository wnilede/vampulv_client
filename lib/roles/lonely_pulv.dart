import 'package:darq/darq.dart';
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
    // If there are no ordinary vampulvs, no VampulvRule is created by normal means. This reaction is to create one in that case.
    reactions.add(
      RoleReaction<GameBeginsEvent>(
          priority: 200,
          onApply: (event, game, player) {
            if (game.rules.any((rule) => rule is VampulvRule)) {
              return game.copyWith(rules: game.rules.append(VampulvRule()).toList());
            }
          }),
    );
  }
}