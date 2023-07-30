import 'dart:math' as math;

import 'package:darq/darq.dart';

import '../input_handlers/confirm_child_input_handlers.dart';
import 'event.dart';
import 'player.dart';
import 'rule.dart';
import 'standard_events.dart';

class StandardRule extends Rule {
  StandardRule()
      : super(reactions: [
          // Set game night field when event is sent.
          RuleReaction<DayBeginsEvent>(
            priority: 0,
            onApply: (event, game) => [
              game.copyWith(isNight: false),
              'Dag ${game.dayNumber} startade.',
            ],
          ),
          // Set game night field when event is sent
          RuleReaction<NightBeginsEvent>(
            priority: 0,
            onApply: (event, game) => [
              game.copyWith(
                isNight: true,
                dayNumber: game.dayNumber + 1,
              ),
              'Natt ${game.dayNumber + 1} startade.',
            ],
          ),
          // Change players lives on hurt events. Lives can be bigger than max lives and smaller than 0 after this if it is night.
          RuleReaction<HurtEvent>(
            priority: 0,
            onApply: (event, game) {
              if (event.livesLost == 0) return null;
              final Player player = game.playerFromId(event.playerId);
              final livesAfterwards = player.lives - event.livesLost;
              if (event.appliedMorning) {
                return player.copyWith(lives: livesAfterwards);
              }
              return [
                player.copyWith(lives: math.min(math.max(livesAfterwards, 0), player.maxLives)),
                if (player.alive && player.lives > 0 && livesAfterwards <= 0) DieEvent(playerId: player.id, appliedMorning: false),
              ];
            },
          ),
          // Cap lives for all players and send die events if neccessary.
          RuleReaction<DayBeginsEvent>(
            priority: 0,
            onApply: (event, game) => [
              ...game.alivePlayers // Cap players with too many lives
                  .where((player) => player.lives > player.maxLives)
                  .map((player) => player.copyWith(lives: player.maxLives)),
              ...game.alivePlayers // Cap players with negative amount of lives
                  .where((player) => player.lives < 0)
                  .map((player) => player.copyWith(lives: 0)),
              ...game.alivePlayers // Send die event for players without positive lives
                  .where((player) => player.lives <= 0)
                  .map((dyingPlayer) => DieEvent(playerId: dyingPlayer.id, appliedMorning: false)),
            ],
          ),
          // Set player field and notify everyone when die event is sent.
          RuleReaction<DieEvent>(
            priority: 0,
            onApply: (event, game) {
              final dyingPlayer = game.playerFromId(event.playerId);
              return [
                ...game.alivePlayers.map((player) {
                  return player.id == dyingPlayer.id
                      ? player.copyWith(
                          alive: false,
                          unhandledInputHandlers:
                              player.unhandledInputHandlers.append(EarlyConfirmChildInputHandler.withText('Du dog!')).toList())
                      : player.copyWith(
                          unhandledInputHandlers: player.unhandledInputHandlers
                              .append(EarlyConfirmChildInputHandler.withText('${dyingPlayer.name} dog!'))
                              .toList());
                }),
                '${dyingPlayer.name} dog.',
              ];
            },
          ),
          // Set game field when GameEndsEvent is sent.
          RuleReaction<GameEndsEvent>(
            priority: 0,
            onApply: (event, game) => game.copyWith(isFinished: true),
          ),
          // If the game is finished, a new day cannot start.
          RuleReaction<DayBeginsEvent>(
            priority: 1000,
            onApply: (event, game) {
              if (game.isFinished) return EventResult.cancel;
              return null;
            },
          ),
          // If the game is finished, a new night cannot start.
          RuleReaction<NightBeginsEvent>(
            priority: 1000,
            onApply: (event, game) {
              if (game.isFinished) return EventResult.cancel;
              return null;
            },
          ),
        ]);
}

class NightSummaryRule extends Rule {
  List<int?> playersLives = [];

  NightSummaryRule() {
    // Save states before the night starts to compare with later.
    reactions.add(RuleReaction<NightBeginsEvent>(
      priority: 50,
      onApply: (event, game) {
        playersLives = game.players.map((player) => player.alive ? player.lives : null).toList();
      },
    ));
    // Show everyone the summary.
    reactions.add(RuleReaction<DayBeginsEvent>(
      priority: -40,
      onApply: (event, game) {
        final livesChanges = <String>[];
        for (int i = 0; i < game.players.length; i++) {
          if (playersLives[i] == null || !game.players[i].alive) {
            continue;
          }
          final livesLost = playersLives[i]! - game.players[i].lives;
          if (livesLost > 0) {
            livesChanges.add('${game.players[i].name} skadades $livesLost liv');
          }
          if (livesLost < 0) {
            livesChanges.add('${game.players[i].name} helades ${-livesLost} liv');
          }
        }
        return [
          ...game.alivePlayers.map((player) => player.copyWith(
              unhandledInputHandlers: player.unhandledInputHandlers
                  .append(EarlyConfirmChildInputHandler.withText(
                      livesChanges.isEmpty ? 'Ingen skadades under natten!' : livesChanges.map((change) => '$change under natten!').join('\n')))
                  .toList())),
          if (livesChanges.isNotEmpty) 'Spelares livs förändrades under natten${livesChanges.map((change) => '\n - $change.').join()}',
        ];
      },
    ));
  }
}
