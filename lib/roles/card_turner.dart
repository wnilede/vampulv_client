import 'package:darq/darq.dart';
import 'package:flutter/material.dart';

import '../components/player_map.dart';
import '../components/role_card_view.dart';
import '../game_logic/log_entry.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/confirm_child_input_handlers.dart';
import '../input_handlers/input_handler.dart';

class CardTurner extends Role {
  bool someoneDiedToday = false;
  int? seenPlayerId;
  int? seeingPlayerId;

  CardTurner() : super(type: RoleType.cardTurner) {
    reactions.add(RoleReaction<DieEvent>(
      priority: -60,
      worksAfterDeath: true,
      onApply: (event, game, owner) {
        someoneDiedToday = true;
        return null;
      },
    ));
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -40,
      onApply: (event, game, owner) {
        if (!someoneDiedToday) {
          return null;
        }
        someoneDiedToday = false;

        final restrictions = game.alivePlayers
                    .where((other) => other.id != owner.id && other.id != seenPlayerId && other.id != seeingPlayerId)
                    .length >=
                2
            ? CardTurnerRestrictions.notSamePlayers // There are at least two other players alive not chosen before.
            : game.alivePlayers.any((other) => other.id != owner.id && other.id != seenPlayerId && other.id != seeingPlayerId) &&
                    game.alivePlayers.any((other) => other.id != owner.id && (other.id == seenPlayerId || other.id == seeingPlayerId))
                ? game.alivePlayers.where((other) => other.id != owner.id).length >= 3
                    ? CardTurnerRestrictions
                        .onePlayerCanBeSameNotForced // There are exactly 3 other players alive, and exactly 2 of them were chosen before.
                    : CardTurnerRestrictions
                        .onePlayerCanBeSameForced // There are exactly 2 other players alive, and exactly one of them was chosen before.
                : game.alivePlayers.where((other) => other.id != owner.id).length >= 2
                    ? CardTurnerRestrictions.bothPlayersCanBeSame // There are exactly 2 other players alive, and both were chosen before.
                    : game.alivePlayers.length >= 2
                        ? CardTurnerRestrictions.canSelectSelf // The owner of this card is alive, and there are exactly 1 other player alive.
                        : CardTurnerRestrictions.cannotUsePower; // There are no other players alive.

        if (restrictions == CardTurnerRestrictions.cannotUsePower) {
          return null;
        }

        return CardTurnerObserverInputHandler(
          role: this,
          ownerId: owner.id,
          restrictions: restrictions,
        );
      },
    ));
  }
}

class CardTurnerObserverInputHandler extends InputHandler {
  CardTurnerObserverInputHandler({
    required CardTurner role,
    required int ownerId,
    required CardTurnerRestrictions restrictions,
  }) : super(
          title: 'Kortvändare',
          description: 'Välj observatör för &cardTurner',
          widget: PlayerMap(
            description: 'Välj spelaren som ska se ett av någon annans kort',
            numberSelected: 1,
            canSelectSelf: restrictions == CardTurnerRestrictions.canSelectSelf,
            selectablePlayerFilter: switch (restrictions) {
              CardTurnerRestrictions.notSamePlayers => [
                  if (role.seeingPlayerId != null) role.seeingPlayerId!,
                  if (role.seenPlayerId != null) role.seenPlayerId!,
                ],
              CardTurnerRestrictions.onePlayerCanBeSameNotForced => [
                  role.seeingPlayerId!,
                ],
              CardTurnerRestrictions.onePlayerCanBeSameForced => [
                  if (role.seenPlayerId == null) role.seeingPlayerId!,
                  if (role.seeingPlayerId == null) role.seenPlayerId!, // In this case we use a whitelist instead.
                ],
              CardTurnerRestrictions.bothPlayersCanBeSame => [
                  role.seeingPlayerId!,
                ],
              CardTurnerRestrictions.canSelectSelf => [
                  if (role.seeingPlayerId != null) role.seeingPlayerId!,
                  if (role.seeingPlayerId == null && role.seenPlayerId != null) role.seenPlayerId!, // In this case we use a whitelist instead.
                ],
              CardTurnerRestrictions.cannotUsePower => throw ArgumentError.value(restrictions),
            },
            filterIsWhitelist: restrictions == CardTurnerRestrictions.onePlayerCanBeSameForced && role.seeingPlayerId == null ||
                restrictions == CardTurnerRestrictions.canSelectSelf && role.seeingPlayerId == null && role.seenPlayerId != null,
            reasonForbidden: 'Du kan inte välja samma spelare två nätter i rad.',
            onDone: null,
          ),
          resultApplyer: (input, game, string) {
            final choosedId = int.tryParse(input.message);

            if (choosedId == null) {
              role.seenPlayerId = null;
              role.seeingPlayerId = null;
              return 'Du valde att inte använda din kortvändare på någon.';
            }

            return CardTurnerObservedInputHandler(
              role: role,
              seeingPlayerId: choosedId,
              seeingPlayerName: game.playerFromId(choosedId).name,
              restrictions: restrictions,
            );
          },
        );
}

class CardTurnerObservedInputHandler extends InputHandler {
  CardTurnerObservedInputHandler({
    required CardTurner role,
    required int seeingPlayerId,
    required String seeingPlayerName,
    required CardTurnerRestrictions restrictions,
  }) : super(
          title: 'Kortvändare',
          description: 'Välj observerad för &cardTurner',
          widget: PlayerMap(
            description: 'Välj spelaren vars ena kort ska bli sett av $seeingPlayerName',
            numberSelected: 1,
            canSelectSelf: restrictions == CardTurnerRestrictions.canSelectSelf,
            selectablePlayerFilter: [
              seeingPlayerId,
              ...switch (restrictions) {
                CardTurnerRestrictions.notSamePlayers => [
                    if (role.seenPlayerId != null) role.seenPlayerId!,
                    if (role.seeingPlayerId != null) role.seeingPlayerId!,
                  ],
                CardTurnerRestrictions.onePlayerCanBeSameNotForced => [
                    if (role.seenPlayerId != null) role.seenPlayerId!,
                    if (seeingPlayerId == role.seenPlayerId && role.seeingPlayerId != null) role.seeingPlayerId!,
                  ],
                CardTurnerRestrictions.onePlayerCanBeSameForced => [],
                CardTurnerRestrictions.bothPlayersCanBeSame => [],
                CardTurnerRestrictions.canSelectSelf => [],
                CardTurnerRestrictions.cannotUsePower => throw ArgumentError.value(restrictions),
              },
            ],
            reasonForbidden: 'Du kan inte välja samma spelare två nätter i rad.',
            onDone: null,
          ),
          resultApplyer: (input, game, string) {
            role.seenPlayerId = int.tryParse(input.message);
            role.seeingPlayerId = seeingPlayerId;

            if (role.seenPlayerId == null) {
              role.seeingPlayerId = null;
              return 'Du valde att inte använda din kortvändare på någon.';
            }

            final seenPlayer = game.playerFromId(int.parse(input.message));
            final seenRole = seenPlayer.roles[game.randomGenerator.nextInt(seenPlayer.roles.length)];

            return [
              game.copyWithPlayerModification(
                seeingPlayerId,
                (seeingPlayer) => seeingPlayer.copyWith(
                    unhandledInputHandlers: seeingPlayer.unhandledInputHandlers
                        .append(LateConfirmChildInputHandler(
                          description: 'See roll visad av &cardTurner',
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Någon har använt en &cardTurner för att visa dig att en av rollerna som ${seenPlayer.name} har är',
                                    textAlign: TextAlign.center),
                                RoleTypeCardView(seenRole.type),
                              ],
                            ),
                          ),
                        ))
                        .toList()),
              ),
              LogEntry(
                playerVisibleTo: seeingPlayerId,
                value: 'Någons &cardTurner visade dig att ${seenPlayer.name} har rollen ${seenRole.type.displayName}.',
              ),
              'Din &cardTurner visade $seeingPlayerName en av rollerna ägd av ${seenPlayer.name}.',
            ];
          },
        );
}

enum CardTurnerRestrictions {
  notSamePlayers,
  onePlayerCanBeSameNotForced,
  onePlayerCanBeSameForced,
  bothPlayersCanBeSame,
  canSelectSelf,
  cannotUsePower,
}
