import 'dart:math' as math;

import 'package:darq/darq.dart';

import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';
import 'villager.dart';

class Drunk extends Villager {
  static const int nightActivated = 3;

  Drunk() {
    type = RoleType.drunk;
    reactions.add(
      RoleReaction<NightBeginsEvent>(
        priority: 60,
        onApply: (event, game, player) => game.dayNumber >= nightActivated
            ? LateConfirmChildInputHandler.withText(
                'Det visar sig att en av dina roller var &drunk, förklädd som en vanlig &villager! Du kommer nu att få nya roller.',
                onConfirm: (input, game, owner) {
                  final shuffledDeck = game.rolesInDeck.randomize(game.randomGenerator).toList();
                  final numberNewRoles = math.min(shuffledDeck.length, game.configuration.rolesPerPlayer);
                  return [
                    game.copyWith(rolesInDeck: shuffledDeck.sublist(numberNewRoles)),
                    owner.copyWith(roles: [
                      ...owner.roles.randomize(game.randomGenerator).take(game.configuration.rolesPerPlayer - numberNewRoles),
                      ...game.rolesInDeck.take(numberNewRoles),
                    ]),
                    '&Drunk aktiverades och du fick nya roller',
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
  String getSummary(Game game, Player owner) => RoleType.villager.summary;
  @override
  String getDescription(Game game, Player owner) => RoleType.villager.description;
  @override
  String getImageName(Game game, Player owner) => '${RoleType.villager.name}$image';
}
