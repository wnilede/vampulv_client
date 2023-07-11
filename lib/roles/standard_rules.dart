import 'package:darq/darq.dart';
import 'package:vampulv/binary_choice.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';

class StandardRule extends Rule {
  StandardRule()
      : super(reactions: [
          // Set game night field when event is sent.
          RuleReaction(
            priority: 0,
            filter: EventType.dayBegins,
            applyer: (event, game) => game.copyWith(isNight: false),
          ),
          // Set game night field when event is sent.
          RuleReaction(
            priority: 0,
            filter: EventType.nightBegins,
            applyer: (event, game) => game.copyWith(isNight: true),
          ),
          // Change players lives on hurt events. Lives can be bigger than max lives and smaller than 0 after this.
          RuleReaction(
            priority: 0,
            filter: EventType.playerIsHurt,
            applyer: (event, game) {
              final castedEvent = event as HurtEvent;
              if (castedEvent.livesLost == 0) return null;
              final Player previousPlayer = game.playerFromId(castedEvent.playerId);
              return game.copyWithPlayer(previousPlayer.copyWith(lives: previousPlayer.lives - castedEvent.livesLost));
            },
          ),
          // Cap lives for all players and send die events if neccessary.
          RuleReaction(
            priority: 40,
            filter: EventType.dayBegins,
            applyer: (event, game) {
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
                cappedPlayers //
                    .where((player) => player.lives == 0)
                    .map((dyingPlayer) => DieEvent(playerId: dyingPlayer.configuration.id)),
              ];
            },
          ),
          // Set player field when die event is sent.
          RuleReaction(
            priority: 0,
            filter: EventType.playerDies,
            applyer: (event, game) => game.copyWithPlayer(game.playerFromId((event as DieEvent).playerId).copyWith(alive: false)),
          ),
          // Add input handlers for voting when lynching is proposed.
          RuleReaction(
            priority: 0,
            filter: EventType.proposeLynching,
            applyer: (event, game) {
              event as ProposeLynchingEvent;
              Player proposed = game.playerFromId(event.proposedId);
              Player proposer = game.playerFromId(event.proposerId);
              return game.copyWith(
                  players: game.players
                      .map((player) => player.copyWith(
                          lynchingVote: null,
                          unhandledInputHandlers: player.unhandledInputHandlers
                              .append(InputHandler(
                                description: 'Rösta i lynchning av ${proposed.configuration.name}',
                                resultApplyer: (playerInput, game, player) {
                                  // If this is the last player casting the vote, count the votes and send die event if neccessary.
                                  final newGame = game.copyWithPlayer(player.copyWith(lynchingVote: bool.parse(playerInput.message)));
                                  if (newGame.players.every((player) => player.lynchingVote != null) && newGame.players.sum((player) => player.lynchingVote! ? player.votesInLynching : -player.votesInLynching) > 0) {
                                    return [
                                      newGame,
                                      DieEvent(playerId: event.proposedId)
                                    ];
                                  }
                                  return newGame;
                                },
                                widget: BinaryChoice(
                                  title: '${proposer.configuration.name} föreslår lynchning av ${proposed.configuration.name}',
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
