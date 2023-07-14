import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/seer.dart';
import 'package:vampulv/roles/standard_events.dart';

class ApprenticeSeer extends Role {
  ApprenticeSeer()
      : super(
          type: RoleType.apprenticeSeer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 25,
              onApply: (event, game, player) => game.players.any((player) => player.alive && player.roles.whereType<Seer>().isNotEmpty) ? null : SeerTargetInputHandler(player.id),
            )
          ],
        );
}
