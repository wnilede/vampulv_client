import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:xrandom/xrandom.dart';

part 'game.freezed.dart';

/// A position in a game of vampulv. A list of events and a configuration should be enough to recreate a game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required Xorshift32 randomGenerator,
    required List<Player> players,
    @Default([]) List<Rule> rules,
    @Default([]) List<Event> unhandledEvents,
    @Default(false) bool isNight,
  }) = _Game;

  const Game._();

  factory Game.fromConfiguration(GameConfiguration configuration) {
    assert(configuration.roles.length >= configuration.players.length * configuration.rolesPerPlayer);
    final randomGenerator = Xorshift32(configuration.randomSeed);
    final players = <Player>[];
    final shuffledRoles = configuration.roles.randomize().toList();
    for (int i = 0; i < configuration.players.length; i++) {
      players.add(Player(
        configuration: configuration.players[i],
        roles: shuffledRoles
            .sublist(
              configuration.rolesPerPlayer * i,
              configuration.rolesPerPlayer * (i + 1),
            )
            .map((roleType) => Role.fromType(roleType))
            .toList(),
        lives: configuration.maxLives,
      ));
    }
    return Game(
      randomGenerator: randomGenerator,
      players: players,
    )._runUntilInput();
  }

  factory Game.fromEvents(GameConfiguration configuration, List<NetworkMessage> events) {
    Game game = Game.fromConfiguration(configuration);
    for (NetworkMessage event in events) {
      game = game.applyChange(event);
    }
    return game;
  }

  Game applyChange(NetworkMessage change) {
    final ruleReactions = rules
        .map(
          (rule) => rule.reactions,
        )
        .flatten()
        .orderBy((reaction) => reaction.priority)
        .toList();
    final playerReactionPairs = players
        .map(
          (player) => player.roles
              .map(
                (role) => role.reactions,
              )
              .flatten()
              .map(
                (reaction) => (
                  player,
                  reaction,
                ),
              ),
        )
        .flatten()
        .orderBy((playerRole) => playerRole.$2.priority)
        .toList();
    Game resultingGame = this;
    while (ruleReactions.isNotEmpty || playerReactionPairs.isNotEmpty) {
      if (playerReactionPairs.isEmpty || ruleReactions.isNotEmpty && ruleReactions[0].priority > playerReactionPairs[0].$2.priority) {
        final reactionResult = ruleReactions[0].applyer(resultingGame);
        switch (reactionResult) {
          case Game:
            resultingGame = reactionResult;
            break;
          case Event:
            resultingGame = resultingGame.copyWith(unhandledEvents: unhandledEvents.append(reactionResult).toList());
            break;
          default:
            throw UnsupportedError("When calling applyer on reaction in rule, the returned type was '${reactionResult.runtimeType}'.");
        }
        resultingGame = ruleReactions[0].applyer(resultingGame);
        ruleReactions.removeAt(0);
      } else {
        final owner = playerReactionPairs[0].$1;
        dynamic reactionResult = playerReactionPairs[0].$2.applyer(resultingGame, owner);
        switch (reactionResult) {
          case Game:
            resultingGame = reactionResult;
            break;
          case InputHandler:
            reactionResult = owner.copyWith(unhandledInputHandlers: owner.unhandledInputHandlers.append(reactionResult).toList());
          case Player:
            final newPlayers = [
              ...resultingGame.players,
            ];
            newPlayers[newPlayers.indexWhere(((player) => player.configuration.id == owner.configuration.id))] = reactionResult;
            resultingGame = resultingGame.copyWith(players: newPlayers);
            break;
          default:
            throw UnsupportedError("When calling applyer on reaction in role, the returned type was '${reactionResult.runtimeType}'.");
        }
        playerReactionPairs.removeAt(0);
      }
      _runUntilInput();
    }
    return resultingGame;
  }

  Game _runUntilInput() {
    Game oldResult = this;
    while (true) {
      final result = _runOneStep();
      if (result == null) {
        return oldResult;
      } else {
        oldResult = result;
      }
    }
  }

  Game? _runOneStep() {
    if (isNight && players.every((player) => player.unhandledInputHandlers.isEmpty) && unhandledEvents.isEmpty) {
      return copyWith(isNight: false);
    }
    return null;
  }
}
