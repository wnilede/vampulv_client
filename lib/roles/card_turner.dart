import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/role_card_view.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class CardTurner extends Role {
  bool someoneDiedToday = false;
  int? seenPlayerId;
  int? seeingPlayerId;

  CardTurner() : super(type: RoleType.cardTurner) {
    reactions.add(RoleReaction<DieEvent>(
      priority: -60,
      onApply: (event, game, player) {
        someoneDiedToday = true;
        return null;
      },
    ));
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -40,
      onApply: (event, game, player) {
        if (!someoneDiedToday) return null;
        someoneDiedToday = false;

        return InputHandler(
          description: 'Välj observatör för kortvändaren',
          identifier: 'card-turner-choose-observer',
          widget: PlayerMap(
            selectablePlayerFilter: [
              if (seeingPlayerId != null) seeingPlayerId!,
              player.configuration.id,
            ],
            onDone: null,
            description: 'Välj spelaren som ska se ett av någon annans kort',
            numberSelected: 1,
          ),
          resultApplyer: (input, game, string) {
            seeingPlayerId = int.tryParse(input.message);
            if (seeingPlayerId == null) {
              seenPlayerId = null;
              return null;
            }
            final seeingPlayer = game.playerFromId(seeingPlayerId!);

            return InputHandler(
                description: 'Välj observerad för kortvändaren',
                identifier: 'card-turner-choose-observed',
                widget: PlayerMap(
                  selectablePlayerFilter: [
                    if (seeingPlayerId != null) seeingPlayerId!,
                    if (seenPlayerId != null) seenPlayerId!,
                    player.configuration.id,
                  ],
                  onDone: null,
                  description: 'Välj spelaren vars ena kort ska bli sett av ${seeingPlayer.configuration.name}',
                  numberSelected: 1,
                ),
                resultApplyer: (input, game, string) {
                  seenPlayerId = int.tryParse(input.message);
                  if (seenPlayerId == null) {
                    seeingPlayerId = null;
                    return null;
                  }
                  final seenPlayer = game.playerFromId(int.parse(input.message));
                  final seenRole = seenPlayer.roles[game.randomGenerator.nextInt(seenPlayer.roles.length)];

                  return game.copyWithPlayer(seeingPlayer.copyWith(
                      unhandledInputHandlers: seeingPlayer.unhandledInputHandlers
                          .append(InputHandler.confirmChild(
                            description: 'See roll visat av kortvändare',
                            identifier: 'role-${seenRole.type.name}-of-${seenPlayer.configuration.id}-shown-by-card-turner-of-${player.configuration.id}',
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('En av rollerna som ${seenPlayer.configuration.name} har är', textAlign: TextAlign.center),
                                  RoleCardView(seenRole.type),
                                ],
                              ),
                            ),
                          ))
                          .toList()));
                });
          },
        );
      },
    ));
  }
}
