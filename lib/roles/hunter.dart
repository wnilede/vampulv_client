import 'package:darq/darq.dart';
import 'package:vampulv/input_handlers/blocking_input_handler.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Hunter extends Role {
  Hunter()
      : super(type: RoleType.hunter, reactions: [
          RoleReaction<DieEvent>(
            priority: -20,
            worksAfterDeath: true,
            onApply: (event, game, player) => event.playerId == player.id && game.alivePlayers.isNotEmpty
                ? [
                    game.players
                        .map((other) =>
                            other.copyWith(unhandledInputHandlers: other.unhandledInputHandlers.append(HunterBlockingInputHanlder()).toList()))
                        .toList(),
                    HunterTargetInputHandler(),
                  ]
                : null,
          )
        ]);
}

class HunterTargetInputHandler extends InputHandler {
  HunterTargetInputHandler()
      : super(
          description: 'Välj spelare att skjuta med jägaren',
          resultApplyer: (input, game, player) {
            final shoot = game.playerFromId(int.parse(input.message));
            return [
              ...game.players
                  .map((other) =>
                      // Remove the blocking input handler created earlier so that they can continue with their other input handlers.
                      other.copyWith(
                        unhandledInputHandlers: other.unhandledInputHandlers
                            .exclude(other.unhandledInputHandlers.firstWhere((handler) => handler is HunterBlockingInputHanlder))
                            .append(EarlyConfirmChildInputHandler.withText(
                                '${player.name} dör, men var en jägare, och skjuter ${shoot.name}, som därför förlorar ett liv!'))
                            .toList(),
                      ))
                  .toList(),
              HurtEvent(playerId: shoot.id, appliedMorning: false),
              LogEntry(value: '${player.name} skjuter ${shoot.name} med en jägare.', playerVisibleTo: null),
            ];
          },
          widget: PlayerMap(
            numberSelected: 1,
            description: 'Välj spelare att använda jägaren på',
            onDone: null,
          ),
        );
}

class HunterBlockingInputHanlder extends BlockingInputHandler {
  HunterBlockingInputHanlder() : super();
}
