import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
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

        return CardTurnerObserverInputHandler(
          role: this,
          ownerId: player.configuration.id,
        );
      },
    ));
  }
}

class CardTurnerObserverInputHandler extends InputHandler {
  CardTurnerObserverInputHandler({required CardTurner role, required int ownerId})
      : super(
          description: 'Välj observatör för kortvändaren',
          identifier: 'card-turner-choose-observer',
          widget: PlayerMap(
            selectablePlayerFilter: [
              if (role.seeingPlayerId != null) role.seeingPlayerId!,
              ownerId,
            ],
            identifier: 'card-turner-choose-observer',
            description: 'Välj spelaren som ska se ett av någon annans kort',
            numberSelected: 1,
          ),
          resultApplyer: (input, game, string) {
            role.seeingPlayerId = int.tryParse(input.message);
            if (role.seeingPlayerId == null) {
              role.seenPlayerId = null;
              return null;
            }

            return CardTurnerObservedInputHandler(
              role: role,
              ownerId: ownerId,
              seeingPlayer: game.playerFromId(role.seeingPlayerId!),
            );
          },
        );
}

class CardTurnerObservedInputHandler extends InputHandler {
  CardTurnerObservedInputHandler({required CardTurner role, required int ownerId, required Player seeingPlayer})
      : super(
          description: 'Välj observerad för kortvändaren',
          identifier: 'card-turner-choose-observed',
          widget: PlayerMap(
            selectablePlayerFilter: [
              if (role.seeingPlayerId != null) role.seeingPlayerId!,
              if (role.seenPlayerId != null) role.seenPlayerId!,
              ownerId,
            ],
            onDone: null,
            description: 'Välj spelaren vars ena kort ska bli sett av ${seeingPlayer.configuration.name}',
            numberSelected: 1,
          ),
          resultApplyer: (input, game, string) {
            role.seenPlayerId = int.tryParse(input.message);
            if (role.seenPlayerId == null) {
              role.seeingPlayerId = null;
              return null;
            }
            final seenPlayer = game.playerFromId(int.parse(input.message));
            final seenRole = seenPlayer.roles[game.randomGenerator.nextInt(seenPlayer.roles.length)];

            return game.copyWithPlayer(seeingPlayer.copyWith(
                unhandledInputHandlers: seeingPlayer.unhandledInputHandlers
                    .append(ConfirmChildInputHandler(
                      description: 'See roll visat av kortvändare',
                      identifier: 'role-${seenRole.type.name}-of-${seenPlayer.configuration.id}-shown-by-card-turner-of-$ownerId',
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
          },
        );
}
