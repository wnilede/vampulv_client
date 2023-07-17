import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/hoodler.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';

class Tanner extends Role {
  bool diedByLynching = false;

  Tanner() : super(type: RoleType.tanner) {
    reactions.add(RoleReaction<GameEndsEvent>(
      priority: 7,
      worksAfterDeath: true,
      onApply: (event, game, player) => player.copyWith(
        // If we also have a hoodler role, we must also win according to that. Hoodlers already did their calculations before, so we use that result.
        isWinner: diedByLynching && (player.roles.whereType<Hoodler>().isEmpty || player.isWinner),
      ),
    ));
    reactions.add(RoleReaction<LynchingDieEvent>(
      priority: -60,
      worksAfterDeath: true,
      onApply: (event, game, player) {
        if (event.playerId == player.id) {
          diedByLynching = true;
        }
        return null;
      },
    ));
  }

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {
        'Har blivit lynchad': diedByLynching ? 'Ja' : 'Nej',
      };
}
