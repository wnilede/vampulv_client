import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/roles/lycan.dart';
import 'package:vampulv/game_logic/role.dart';
import 'package:vampulv/game_logic/role_type.dart';
import 'package:vampulv/game_logic/standard_events.dart';
import 'package:vampulv/roles/vampulv.dart';
import 'package:vampulv/components/player_map.dart';

class Seer extends Role {
  Seer()
      : super(
          type: RoleType.seer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 30,
              onApply: (event, game, player) => SeerTargetInputHandler(player.id),
            )
          ],
        );
}

class SeerTargetInputHandler extends InputHandler {
  SeerTargetInputHandler(int ownerId)
      : super(
          description: 'Välj spelare att använda spådamen på',
          resultApplyer: (input, game, string) {
            final seenPlayer = game.playerFromId(int.parse(input.message));
            final seenPlayerIsVampulv = seenPlayer.roles.any((role) => role is Vampulv || role is Lycan);
            return [
              EarlyConfirmChildInputHandler.withText('${seenPlayer.name} är ${seenPlayerIsVampulv ? '' : 'inte '}en vampulv!'),
              'Du använde din spådam för att se att ${seenPlayer.name} ${seenPlayerIsVampulv ? '' : 'inte '}var en vampulv.',
            ];
          },
          widget: PlayerMap(
            description: 'Välj vem du vill se huruvida de är vampulv',
            numberSelected: 1,
            selectablePlayerFilter: [
              ownerId,
            ],
            onDone: null,
          ),
        );
}
