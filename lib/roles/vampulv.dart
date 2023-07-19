import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/input_handlers/blocking_input_handler.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Vampulv extends Role {
  bool hasChoosen = false;
  int? playerIdAttacked;

  Vampulv() : super(type: RoleType.vampulv) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: 100,
      onApply: (event, game, owner) {
        hasChoosen = false;
        return [
          VampulvTargetInputHandler(setResult: setAttacked),
          VampulvBlockingInputHandler(),
        ];
      },
    ));
  }

  void setAttacked(int? id) {
    playerIdAttacked = id;
    hasChoosen = true;
  }
}

class VampulvRule extends Rule {
  VampulvRule()
      : super(reactions: [
          RuleReaction<GameBeginsEvent>(
              priority: -20,
              onApply: (event, game) {
                final vampulvs = game.players.where((player) => player.roles.whereType<Vampulv>().isNotEmpty);
                return vampulvs.map((messageFor) {
                  final otherVampulvsNames = vampulvs //
                      .where((vampulv) => vampulv.id != messageFor.id)
                      .map((vampulv) => vampulv.name)
                      .toList();
                  final message = otherVampulvsNames.isEmpty
                      ? 'Du är den enda vampulven!'
                      : otherVampulvsNames.length == 1
                          ? 'Den andra vampulven är ${otherVampulvsNames.single}!'
                          : 'De andra vampulverna är ${otherVampulvsNames.skip(1).join(', ')} och ${otherVampulvsNames[0]}!';
                  return [
                    messageFor.copyWith(unhandledInputHandlers: messageFor.unhandledInputHandlers.append(EarlyConfirmChildInputHandler.withText(message)).toList()),
                    LogEntry(
                      value: 'Du såg vilka som var vampulver:${[
                        'du själv',
                        ...otherVampulvsNames,
                      ].map((name) => '\n - $name').join()}',
                      playerVisibleTo: messageFor.id,
                    ),
                  ];
                });
              }),
          RuleReaction<Event>(
              priority: -50,
              onApply: (event, game) {
                if (event is! GameBeginsEvent && event is! DieEvent) return null;
                return game.alivePlayers.every((player) => player.roles.any((role) => role is Vampulv)) || //
                        game.alivePlayers.every((player) => player.roles.all((role) => role is! Vampulv))
                    ? GameEndsEvent()
                    : null;
              }),
          RuleReaction<EndScoringEvent>(
              priority: 100,
              onApply: (event, game) {
                final vampulvsWon = game.alivePlayers.isNotEmpty &&
                    game.alivePlayers.every(
                      (player) => player.roles.any((role) => role is Vampulv),
                    );
                final civiliansWon = game.alivePlayers.isNotEmpty && !vampulvsWon;
                return game.players.map(
                  (player) {
                    final isVampulv = player.roles.any((role) => role is Vampulv);
                    return player.copyWith(
                      isWinner: vampulvsWon && isVampulv || civiliansWon && !isVampulv,
                    );
                  },
                ).toList();
              }),
        ]);
}

class VampulvTargetInputHandler extends InputHandler {
  VampulvTargetInputHandler({required void Function(int?) setResult})
      : super(
          description: 'Välj spelare att attackera med vampulv',
          identifier: 'choose-target-vampulv',
          resultApplyer: (input, game, player) {
            setResult(int.tryParse(input.message));
            final vampulvs = game.alivePlayers.where((player) => player.roles.any((role) => role is Vampulv)).toList();
            if (vampulvs.any((player) => player.alive && player.roles.whereType<Vampulv>().any((role) => !role.hasChoosen))) {
              return null;
            }

            // This was the last vampulv to choose target, so we calculate who is attacked, add HurtEvent if needed, add InputHandlers for the vampulvs to see the result and remove the BlockingInputHandlers.
            final mostVotedForId = vampulvs //
                .map((player) => player.roles)
                .flatten()
                .whereType<Vampulv>()
                .countBy((vampulvRole) => vampulvRole.playerIdAttacked)
                .groupByValue(keySelector: (idFrequency) => idFrequency.value, valueSelector: (idFrequency) => idFrequency.key)
                .max((group1, group2) => group1.key - group2.key)
                .randomSubset(1, game.randomGenerator)
                .single;
            final resultSummary = 'Vampulverna attackerade ${mostVotedForId == null ? 'ingen' : game.playerFromId(mostVotedForId).name}!\n${vampulvs //
                .map(
                  (player) => '${player.name} röstade på ${player.roles.whereType<Vampulv>() //
                      .map((role) => role.playerIdAttacked == null //
                          ? 'att inte attackera någon' //
                          : game.playerFromId(role.playerIdAttacked!).name).join(' och ')}',
                ).join('\n')}';
            return [
              ...vampulvs.map((vampulv) => [
                    vampulv.copyWith(
                        unhandledInputHandlers: vampulv.unhandledInputHandlers //
                            .where((handler) => handler is! VampulvBlockingInputHandler)
                            .append(EarlyConfirmChildInputHandler(
                              description: 'Se resultat av vampulvattack',
                              identifier: 'vampulv-result',
                              child: Center(child: Text(resultSummary, textAlign: TextAlign.center)),
                            ))
                            .toList()),
                    LogEntry(
                      playerVisibleTo: vampulv.id,
                      value: resultSummary,
                    ),
                  ]),
              if (mostVotedForId != null) VampulvHurtEvent(playerId: mostVotedForId),
            ];
          },
          widget: PlayerMap(
            description: 'Välj vem vampulverna ska attackera',
            identifier: 'choose-target-vampulv',
            numberSelected: 1,
            canChooseFewer: true,
          ),
        );
}

class VampulvBlockingInputHandler extends BlockingInputHandler {
  VampulvBlockingInputHandler() : super(identifier: 'vampulv-result');
}

class VampulvHurtEvent extends HurtEvent {
  VampulvHurtEvent({required super.playerId}) : super(appliedMorning: true);
}
