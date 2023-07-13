import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/logentry.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Vampulv extends Role {
  int? playerIdAttacked;

  Vampulv() : super(type: RoleType.vampulv) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: 100,
      onApply: (event, game, owner) => VampulvTargetInputHandler(onResult: _setAttacked),
    ));
  }

  void _setAttacked(int? id) {
    playerIdAttacked = id;
  }
}

class VampulvRule extends Rule {
  VampulvRule()
      : super(reactions: [
          RuleReaction<NightBeginsEvent>(
            priority: 50,
            onApply: (event, game) => VampulvsAttackEvent(),
          ),
          RuleReaction<VampulvsAttackEvent>(
              priority: 10,
              onApply: (event, game) {
                final vampulvs = game.players.where((player) => player.alive && player.roles.any((role) => role is Vampulv));
                final mostVotedForId = vampulvs //
                    .map((player) => player.roles)
                    .flatten()
                    .whereType<Vampulv>()
                    .countBy((vampulvRole) => vampulvRole.playerIdAttacked)
                    .groupByValue(keySelector: (idFrequency) => idFrequency.value, valueSelector: (idFrequency) => idFrequency.key)
                    .max((group1, group2) => group1.key - group2.key)
                    .randomSubset(1, game.randomGenerator)
                    .single;
                final resultSummary = 'Vampulverna attackerade ${mostVotedForId == null ? 'ingen' : game.playerFromId(mostVotedForId).configuration.name}!\n${vampulvs //
                    .map(
                      (player) => '${player.configuration.name} röstade på ${player.roles.whereType<Vampulv>() //
                          .map((role) => role.playerIdAttacked == null //
                              ? 'att inte attackera någon' //
                              : game.playerFromId(role.playerIdAttacked!).configuration.name).join(' och ')}',
                    ).join('\n')}';
                return [
                  ...vampulvs.map((vampulv) => [
                        LogEntry(
                          playerVisibleTo: vampulv.configuration.id,
                          value: resultSummary,
                        ),
                        vampulv.copyWith(
                            unhandledInputHandlers: vampulv.unhandledInputHandlers //
                                .append(VampulvResultInputHandler(resultSummary))
                                .toList()),
                      ]),
                  if (mostVotedForId != null) HurtEvent(playerId: mostVotedForId, appliedMorning: true),
                ];
              }),
          RuleReaction<DieEvent>(
              priority: -50,
              onApply: (event, game) {
                final alivePlayers = game.players.where((player) => player.alive);
                return alivePlayers.every((player) => player.roles.any((role) => role is Vampulv)) || //
                        alivePlayers.every((player) => player.roles.all((role) => role is! Vampulv))
                    ? GameEndsEvent()
                    : null;
              }),
          RuleReaction<GameEndsEvent>(
              priority: 10,
              onApply: (event, game) {
                final vampulvsWon = game.players.every(
                  (player) =>
                      !player.alive ||
                      player.roles.any(
                        (role) => role.type == RoleType.vampulv || role.type == RoleType.lonelyPulv,
                      ),
                );
                return game.copyWith(
                  players: game.players
                      .map(
                        (player) => player.copyWith(
                          isWinner: vampulvsWon ==
                              player.roles.any(
                                (role) => role.type == RoleType.vampulv || role.type == RoleType.lonelyPulv,
                              ),
                        ),
                      )
                      .toList(),
                );
              }),
        ]);
}

class VampulvTargetInputHandler extends InputHandler {
  VampulvTargetInputHandler({required void Function(int?) onResult})
      : super(
          description: 'Välj spelare att attakera med vampulv',
          identifier: 'choose-target-vampulv',
          resultApplyer: (input, game, player) {
            onResult(int.tryParse(input.message));
            return null;
          },
          widget: const PlayerMap(
            description: 'Välj vem vampulverna ska attakera',
            identifier: 'choose-target-vampulv',
            numberSelected: 1,
            canChooseFewer: true,
          ),
        );
}

class VampulvResultInputHandler extends ConfirmChildInputHandler {
  VampulvResultInputHandler(String result)
      : super(
          description: 'See resultat av vampulvattack',
          identifier: 'vampulv-result',
          child: Center(child: Text(result, textAlign: TextAlign.center)),
        );
}

class VampulvsAttackEvent extends Event {
  VampulvsAttackEvent() : super(appliedMorning: true);
}
