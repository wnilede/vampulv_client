import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';

class Villager extends Role {
  Villager()
      : super(
          type: RoleType.villager,
          reactions: [
            RoleReaction<GameBeginsEvent>(
              priority: 40,
              onApply: (event, game, player) => player.roles.every((role) => role is Villager) ? player.copyWith(votesInLynching: 2) : null,
            ),
          ],
        );
}
