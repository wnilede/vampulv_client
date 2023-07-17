import 'package:darq/darq.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';

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
                              EarlyConfirmChildInputHandler.withText('Eftersom ${owner.name} hade en självmordsbombare och dog, så skadas grannarna ${playerRight.name} och ${playerLeft.name} varsit liv!'),
                            )
                            .toList()))
                    .toList(),
                HurtEvent(playerId: playerRight.id, appliedMorning: false),
                HurtEvent(playerId: playerLeft.id, appliedMorning: false),
                LogEntry(value: '${owner.namePossissive} självmordsbombare aktiverade och skadade ${playerRight.name} och ${playerLeft.name}.', playerVisibleTo: null),
              ];
            },
          )
        ]);
}
