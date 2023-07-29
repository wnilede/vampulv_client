import '../components/player_map.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';
import '../input_handlers/input_handler.dart';
import 'lycan.dart';
import 'vampulv.dart';

class Seer extends Role {
  Seer()
      : super(
          type: RoleType.seer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 30,
              onApply: (event, game, player) => SeerTargetInputHandler(),
            )
          ],
        );
}

class SeerTargetInputHandler extends InputHandler {
  SeerTargetInputHandler()
      : super(
          title: 'Spådam',
          description: 'Välj spelare att använda &seer på',
          resultApplyer: (input, game, string) {
            final seenPlayer = game.playerFromId(int.parse(input.message));
            final seenPlayerIsVampulv = seenPlayer.roles.any((role) => role is Vampulv || role is Lycan);
            return [
              EarlyConfirmChildInputHandler.withText(
                  '${seenPlayer.name} är ${seenPlayerIsVampulv ? '' : 'inte '}en [&vampulv OR &lonelyPulv OR &lycan]!'),
              'Du använde din spådam för att se att ${seenPlayer.name} ${seenPlayerIsVampulv ? '' : 'inte '}var en [&vampulv OR &lonelyPulv OR &lycan].',
            ];
          },
          widget: PlayerMap(
            description: 'Välj vem du vill se huruvida de är vampulv',
            numberSelected: 1,
            canSelectSelf: false,
            onDone: null,
          ),
        );
}
