import 'package:darq/darq.dart';
import 'package:vampulv/game_logic/game.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/game_logic/player.dart';
import 'package:vampulv/game_logic/role.dart';
import 'package:vampulv/game_logic/role_type.dart';
import 'package:vampulv/game_logic/standard_events.dart';
import 'package:vampulv/roles/villager.dart';

class Drunk extends Villager {
  static const int nightActivated = 3;

  Drunk() {
    type = RoleType.drunk;
    reactions.add(
      RoleReaction<NightBeginsEvent>(
        priority: 60,
        worksAfterDeath: true,
        onApply: (event, game, player) => game.dayNumber >= nightActivated
            ? LateConfirmChildInputHandler.withText(
                'Det visar sig att en av dina roller var fyllot, förklädd som en vanlig bybo! Du kommer nu att få nya roller.',
                onConfirm: (input, game, owner) {
                  final shuffledDeck = game.rolesInDeck.randomize(game.randomGenerator).toList();
                  return [
                    game.copyWith(rolesInDeck: shuffledDeck.sublist(game.configuration.rolesPerPlayer)),
                    owner.copyWith(roles: game.rolesInDeck.sublist(0, game.configuration.rolesPerPlayer)),
                    'Fyllot aktiverades och du fick nya roller',
                  ];
                },
              )
            : null,
      ),
    );
  }

  // These are set so that if you look at this card as the owner, it looks like a villager. When the owner is nonexistent, for example when choosing cards when configuring the game, or when we don't have access to instance specific information, for example when seeing the card with a card turner, it is shown as a drunk instead. The image becomes slightly weird, because it is not randomized together with the other villagers. If there are only 7 villages and 1 drunk, and you see that you have two villages with the same image, you can figure out that one of them must be a drunk.
  @override
  String getDisplayName(Game game, Player owner) => RoleType.villager.displayName;
  @override
  String getDescription(Game game, Player owner) => RoleType.villager.description;
  @override
  String getDetailedDescription(Game game, Player owner) => RoleType.villager.detailedDescription;
  @override
  String getImageName(Game game, Player owner) => '${RoleType.villager.name}$image';
}
