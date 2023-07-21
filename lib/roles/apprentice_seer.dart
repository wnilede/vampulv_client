import 'package:vampulv/game_logic/role.dart';
import 'package:vampulv/game_logic/role_type.dart';
import 'package:vampulv/roles/seer.dart';
import 'package:vampulv/game_logic/standard_events.dart';

class ApprenticeSeer extends Role {
  ApprenticeSeer()
      : super(
          type: RoleType.apprenticeSeer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 25,
              onApply: (event, game, player) =>
                  game.alivePlayers.any((player) => player.roles.whereType<Seer>().isNotEmpty) ? null : SeerTargetInputHandler(player.id),
            )
          ],
        );
}
