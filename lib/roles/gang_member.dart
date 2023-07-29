import 'package:darq/darq.dart';

import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';
import '../utility/list_strings_nicely.dart';

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
                      ? 'Du är den enda gängmedlemmen&gangMember!'
                      : otherGangMemberNames.length == 1
                          ? 'Den andra gängmedlemmen&gangMember är ${otherGangMemberNames.single}!'
                          : 'De andra gängmedlemmarna&gangMember är ${otherGangMemberNames.listedNicelyAnd}!'),
                  'Du såg vilka som var gängmedlemmar&gangMember:${[
                    'du själv',
                    ...otherGangMemberNames,
                  ].map((name) => '\n - $name').join()}',
                ];
              },
            ),
          ],
        );
}
