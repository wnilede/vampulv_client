import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Witch extends Role {
  bool poisonUsed = false;
  bool healingUsed = false;

  Witch() : super(type: RoleType.witch) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -30,
      onApply: (event, game, player) => [
        if (!poisonUsed)
          WitchPoisonInputHandler(usePoison: () {
            poisonUsed = true;
          }),
        if (!healingUsed)
          WitchHealingInputHandler(
            useHealing: () {
              healingUsed = true;
            },
          ),
      ],
    ));
  }

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {
        'Gift använt': poisonUsed ? 'Ja' : 'Nej',
        'Helning använd': healingUsed ? 'Ja' : 'Nej',
      };
}

class WitchPoisonInputHandler extends InputHandler {
  final void Function() usePoison;

  WitchPoisonInputHandler({required this.usePoison})
      : super(
          description: 'Välj spelare att förgifta med häxa',
          identifier: 'witch-poisoning',
          resultApplyer: (input, game, player) {
            final choosen = int.tryParse(input.message);
            if (choosen == null) {
              return null;
            }
            usePoison();
            return [
              HurtEvent(playerId: choosen, appliedMorning: true),
              'Du använde din häxa för att förgifta ${game.playerFromId(choosen)}.',
            ];
          },
          widget: PlayerMap(
            identifier: 'witch-poisoning',
            description: 'Välj vem du vill förgifta med din häxa',
            numberSelected: 1,
            canChooseFewer: true,
          ),
        );
}

class WitchHealingInputHandler extends InputHandler {
  final void Function() useHealing;

  WitchHealingInputHandler({required this.useHealing})
      : super(
          description: 'Välj spelare att hela med häxa',
          identifier: 'witch-healing',
          resultApplyer: (input, game, player) {
            final choosen = int.tryParse(input.message);
            if (choosen == null) {
              return null;
            }
            useHealing();
            return [
              HurtEvent(playerId: choosen, livesLost: -1, appliedMorning: true),
              'Du använde din häxa för att hela ${game.playerFromId(choosen)}.',
            ];
          },
          widget: PlayerMap(
            identifier: 'witch-healing',
            description: 'Välj vem du vill hela med din häxa',
            numberSelected: 1,
            canChooseFewer: true,
          ),
        );
}