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
          // Change players lives on hurt events. Lives can be bigger than max lives and smaller than 0 after this.
          RuleReaction<HurtEvent>(
            priority: 0,
            onApply: (event, game) {
              if (event.livesLost == 0) return null;
              final Player previousPlayer = game.playerFromId(event.playerId);
              return game.copyWithPlayer(previousPlayer.copyWith(lives: previousPlayer.lives - event.livesLost));
            },
          ),
          // Cap lives for all players and send die events if neccessary.
          RuleReaction<DayBeginsEvent>(
            priority: 40,
            onApply: (event, game) => [
              ...game.players // Cap players with too many lives
                  .where((player) => player.alive && player.lives > player.maxLives)
                  .map((player) => player.copyWith(lives: player.maxLives)),
              ...game.players // Cap players with negative amount of lives
                  .where((player) => player.alive && player.lives < 0)
                  .map((player) => player.copyWith(lives: 0)),
              ...game.players // Send die event for players without positive lives
                  .where((player) => player.alive && player.lives <= 0)
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
              return game.players
                  .where((player) => player.alive)
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
