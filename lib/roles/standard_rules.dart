import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/roles/standard_input_handlers.dart';

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
          // Set game night field when event is sent and reset lynchinging ability.
          RuleReaction<NightBeginsEvent>(
            priority: 0,
            onApply: (event, game) => [
              game.copyWith(
                isNight: true,
                players: game.players
                    .map((player) => player.copyWith(
                          lynchingDone: !player.alive,
                          previouslyProposed: [],
                          votesInLynching: 1,
                        ))
                    .toList(),
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
                if (player.alive && livesAfterwards <= 0) DieEvent(playerId: player.id, appliedMorning: false),
              ];
            },
          ),
          // Cap lives for all players and send die events if neccessary.
          RuleReaction<DayBeginsEvent>(
            priority: 40,
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
          // Set player field when die event is sent.
          RuleReaction<DieEvent>(
            priority: 0,
            onApply: (event, game) {
              final player = game.playerFromId(event.playerId);
              return [
                game.copyWithPlayer(player.copyWith(alive: false)),
                '${player.name} dog.',
              ];
            },
          ),
          // Add input handlers for voting when lynching is proposed.
          RuleReaction<ProposeLynchingEvent>(
            priority: 0,
            onApply: (event, game) {
              Player proposed = game.playerFromId(event.proposedId);
              Player proposer = game.playerFromId(event.proposerId);
              return game.alivePlayers
                  .map(
                    (player) => player.copyWith(
                      lynchingVote: null,
                      unhandledInputHandlers: player.unhandledInputHandlers //
                          .append(LynchingVoteInputHandler(proposer: proposer, proposed: proposed))
                          .append(LynchingWaitingResultInputHandler())
                          .toList(),
                    ),
                  )
                  .toList();
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
