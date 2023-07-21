import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import 'seer.dart';

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
