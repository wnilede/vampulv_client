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
              onApply: (event, game, player) =>
                  isMayor(player) ? player.copyWith(votesInLynching: 2) : null,
            ),
          ],
        );

  static bool isMayor(Player owner) =>
      owner.roles.every((role) => role is Villager);

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {
        'Borgmästare': isMayor(owner) ? 'Ja' : 'Nej',
      };
}
