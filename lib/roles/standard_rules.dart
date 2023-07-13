import 'package:darq/darq.dart';
import 'package:vampulv/binary_choice.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';

class StandardRule extends Rule {
  StandardRule()
      : super(reactions: [
          // Set game night field when event is sent.
          RuleReaction<DayBeginsEvent>(
            priority: 0,
            onApply: (event, game) => game.copyWith(isNight: false),
          ),
          // Set game night field when event is sent and reset lynchinging ability.
          RuleReaction<NightBeginsEvent>(
            priority: 0,
            onApply: (event, game) => game.copyWith(
              isNight: true,
              players: game.players
                  .map((player) => player.copyWith(
                        lynchingDone: !player.alive,
                        previouslyProposed: [],
                      ))
                  .toList(),
            ),
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
            onApply: (event, game) {
              final cappedPlayers = game.players.map(
                (player) {
                  if (player.lives < 0) {
                    return player.copyWith(lives: 0);
                  }
                  if (player.lives > player.maxLives) {
                    return player.copyWith(lives: player.maxLives);
                  }
                  return player;
                },
              ).toList();
              return [
                game.copyWith(
                  players: cappedPlayers,
                ),
                ...cappedPlayers //
                    .where((player) => player.lives == 0)
                    .map((dyingPlayer) => DieEvent(playerId: dyingPlayer.configuration.id, priority: 0, appliedMorning: false)),
              ];
            },
          ),
          // Set player field when die event is sent.
          RuleReaction<DieEvent>(
            priority: 0,
            onApply: (event, game) => game.copyWithPlayer(game.playerFromId(event.playerId).copyWith(alive: false)),
          ),
          // Add input handlers for voting when lynching is proposed.
          RuleReaction<ProposeLynchingEvent>(
            priority: 0,
            onApply: (event, game) {
              Player proposed = game.playerFromId(event.proposedId);
              Player proposer = game.playerFromId(event.proposerId);
              final identifier = 'vote-lynching-of-${proposed.configuration.id}-proposed-by-${proposer.configuration.id}';
              return game.copyWith(
                  players: game.players
                      .map((player) => player.copyWith(
                          lynchingVote: null,
                          unhandledInputHandlers: player.unhandledInputHandlers
                              .append(InputHandler(
                                description: 'Rösta i lynchning av ${proposed.configuration.name}',
                                identifier: identifier,
                                resultApplyer: (playerInput, game, player) {
                                  // If this is the last player casting the vote, count the votes and send die event if neccessary.
                                  final newGame = game.copyWithPlayer(player.copyWith(lynchingVote: bool.parse(playerInput.message)));
                                  if (newGame.players.every((player) => player.lynchingVote != null) && newGame.players.sum((player) => player.lynchingVote! ? player.votesInLynching : -player.votesInLynching) > 0) {
                                    return [
                                      newGame,
                                      DieEvent(playerId: event.proposedId, priority: 40, appliedMorning: false),
                                      NightBeginsEvent(),
                                    ];
                                  }
                                  return newGame;
                                },
                                widget: BinaryChoice(
                                  title: '${proposer.configuration.name} föreslår lynchning av ${proposed.configuration.name}',
                                  identifier: identifier,
                                  trueChoice: 'För',
                                  falseChoice: 'Emot',
                                ),
                              ))
                              .toList()))
                      .toList());
            },
          ),
        ]);
}
