import '../components/player_map.dart';
import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/input_handler.dart';

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
          resultApplyer: (input, game, player) {
            final choosen = int.tryParse(input.message);
            if (choosen == null) {
              return null;
            }
            usePoison();
            return [
              HurtEvent(playerId: choosen, appliedMorning: true),
              'Du använde din häxa för att förgifta ${game.playerFromId(choosen).name}.',
            ];
          },
          widget: PlayerMap(
            description: 'Välj vem du vill förgifta med din häxa',
            numberSelected: 1,
            canChooseFewer: true,
            onDone: null,
          ),
        );
}

class WitchHealingInputHandler extends InputHandler {
  final void Function() useHealing;

  WitchHealingInputHandler({required this.useHealing})
      : super(
          description: 'Välj spelare att hela med häxa',
          resultApplyer: (input, game, player) {
            final choosen = int.tryParse(input.message);
            if (choosen == null) {
              return null;
            }
            useHealing();
            return [
              HurtEvent(playerId: choosen, livesLost: -1, appliedMorning: true),
              'Du använde din häxa för att hela ${game.playerFromId(choosen).name}.',
            ];
          },
          widget: PlayerMap(
            description: 'Välj vem du vill hela med din häxa',
            numberSelected: 1,
            canChooseFewer: true,
            onDone: null,
          ),
        );
}
