import 'package:darq/darq.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';

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
          ...game.players
              .map((otherPlayer) => otherPlayer.copyWith(
                  unhandledInputHandlers: otherPlayer.unhandledInputHandlers
                      .append(
                        EarlyConfirmChildInputHandler.withText('${player.name} skulle ha blivit lynchad, men hade en prins och klarade sig därför!'),
                      )
                      .toList()))
              .toList(),
          LogEntry(value: '${player.name} använde sin prins för att undvika att bli lynchad.', playerVisibleTo: null),
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
