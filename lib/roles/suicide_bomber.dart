import 'package:darq/darq.dart';

import '../game_logic/log_entry.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';

class SuicideBomber extends Role {
  SuicideBomber()
      : super(type: RoleType.suicideBomber, reactions: [
          RoleReaction<DieEvent>(
            priority: 5,
            onApply: (event, game, owner) {
              if (event.playerId != owner.id) return null;
              final indexOwner = game.alivePlayers.indexWhere((player) => player.id == owner.id);
              final playerRight = game.alivePlayers[(indexOwner - 1) % game.alivePlayers.length];
              final playerLeft = game.alivePlayers[(indexOwner + 1) % game.alivePlayers.length];
              return [
                ...game.alivePlayers
                    .map((otherPlayer) => otherPlayer.copyWith(
                        unhandledInputHandlers: otherPlayer.unhandledInputHandlers
                            .append(
                              EarlyConfirmChildInputHandler.withText(
                                  'Eftersom ${owner.name} hade en &suicideBomber och dog, så skadas grannarna ${playerRight.name} och ${playerLeft.name} varsitt liv!'),
                            )
                            .toList()))
                    .toList(),
                HurtEvent(playerId: playerRight.id, appliedMorning: false),
                HurtEvent(playerId: playerLeft.id, appliedMorning: false),
                LogEntry(
                    value: '${owner.namePossissive} &suicideBomber aktiverade och skadade ${playerRight.name} och ${playerLeft.name}.',
                    playerVisibleTo: null),
              ];
            },
          )
        ]);
}
