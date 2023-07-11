import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Vampulv extends Role {
  int? playerIdAttacked;

  Vampulv() : super(type: RoleType.vampulv) {
    reactions.add(RoleReaction(
      priority: 100,
      applyer: (event, game, owner) => event.type == EventType.nightBegins
          ? InputHandler(
              description: 'Välj spelare att attakera med vampulv',
              resultApplyer: (input, game, player) {
                _setAttacked(int.tryParse(input.message));
                return null;
              },
              widget: const VampulvChoosingWidget(),
            )
          : null,
    ));
  }

  void _setAttacked(int? id) {
    playerIdAttacked = id;
  }
}

class VampulvRule extends Rule {
  VampulvRule()
      : super(reactions: [
          RuleReaction(
            priority: 50,
            filter: EventType.nightBegins,
            applyer: (event, game) => Event(type: EventType.vampulvsAttacks),
          ),
          RuleReaction(
              priority: 10,
              filter: EventType.vampulvsAttacks,
              applyer: (event, game) {
                final mostVotedForId = game.players //
                    .map((player) => player.roles)
                    .flatten()
                    .whereType<Vampulv>()
                    .countBy((vampulvRole) => vampulvRole.playerIdAttacked)
                    .groupByValue(keySelector: (idFrequency) => idFrequency.value, valueSelector: (idFrequency) => idFrequency.key)
                    .max((group1, group2) => group1.key - group2.key)
                    .randomSubset(1, game.randomGenerator)
                    .single;
                if (mostVotedForId == null) return null;
                return HurtEvent(playerId: mostVotedForId);
              }),
          RuleReaction(
              priority: 10,
              filter: EventType.gameEnds,
              applyer: (event, game) {
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

class VampulvChoosingWidget extends ConsumerWidget {
  const VampulvChoosingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayerMap(
      onDone: (List<Player> selected) {
        ref.read(messageSenderProvider).sendPlayerInput(selected.isEmpty ? 'none' : '${selected.single.configuration.id}');
      },
      description: 'Välj vem vampyrerna ska attakera',
      numberSelected: 1,
      canChooseFewer: true,
    );
  }
}
