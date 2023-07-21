import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';

class Villager extends Role {
  Villager()
      : super(
          type: RoleType.villager,
          reactions: [
            RoleReaction<ProposeLynchingEvent>(
              priority: 40,
              onApply: (event, game, player) => player.roles.every((role) => role is Villager) ? player.copyWith(votesInLynching: 2) : null,
            ),
          ],
        );

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {
        'Borgmästare': owner.roles.every((role) => role is Villager) ? 'Ja' : 'Nej',
      };
}
