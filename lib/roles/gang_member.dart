import 'package:darq/darq.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';

class GangMember extends Role {
  GangMember()
      : super(
          type: RoleType.gangMember,
          reactions: [
            RoleReaction<GameBeginsEvent>(
              priority: -20,
              onApply: (event, game, owner) {
                final otherGangMemberNames = game.players //
                    .where((player) => player.id != owner.id && player.roles.ofType().whereType<GangMember>().isNotEmpty)
                    .map((gangMember) => gangMember.name)
                    .toList();
                return [
                  EarlyConfirmChildInputHandler.withText(otherGangMemberNames.isEmpty
                      ? 'Du är den enda gängmedlemmen!'
                      : otherGangMemberNames.length == 1
                          ? 'Den andra gängmedlemmen är ${otherGangMemberNames.single}!'
                          : 'De andra gängmedlemmarna är ${otherGangMemberNames.skip(1).join(', ')} och ${otherGangMemberNames[0]}!'),
                  'Du såg vilka som var gängmedlemmar:${[
                    'du själv',
                    ...otherGangMemberNames,
                  ].map((name) => '\n - $name').join()}',
                ];
              },
            ),
          ],
        );
}
