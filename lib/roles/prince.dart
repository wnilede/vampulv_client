import 'package:darq/darq.dart';

import '../game_logic/event.dart';
import '../game_logic/game.dart';
import '../game_logic/log_entry.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';

class Prince extends Role {
  bool usedUp = false;

  Prince() : super(type: RoleType.prince) {
    reactions.add(RoleReaction<LynchingDieEvent>(
      priority: 70,
      onApply: (event, game, player) {
        if (event.playerId != player.id || usedUp) {
          return null;
        }
        usedUp = true;
        return [
          ...game.alivePlayers
              .map((otherPlayer) => otherPlayer.copyWith(
                  unhandledInputHandlers: otherPlayer.unhandledInputHandlers
                      .append(
                        EarlyConfirmChildInputHandler.withText(
                            '${player.name} skulle ha blivit lynchad, men hade en &prince och klarade sig därför!'),
                      )
                      .toList()))
              .toList(),
          LogEntry(value: '${player.name} använde sin &prince för att undvika att bli lynchad.', playerVisibleTo: null),
          EventResult.cancel,
        ];
      },
    ));
  }

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {
        'Använd': usedUp ? 'Ja' : 'Nej',
      };
}
