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
    assert(configuration.roles.length >= configuration.players.length * configuration.rolesPerPlayer, 'There are not enough roles for all players.');
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
    )._runUntilInput().applyEvent(Event(type: EventType.nightBegins));
  }

  factory Game.fromInputs(GameConfiguration configuration, List<NetworkMessage> inputs) {
    Game game = Game.fromConfiguration(configuration);
    for (NetworkMessage input in inputs) {
      game = game.applyInput(input);
    }
    return game;
  }

  Game applyEvent(Event event) {
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
        final reactionResult = ruleReactions[0].applyer(event, resultingGame);
        if (reactionResult == null) {
        } else if (reactionResult is Event) {
          resultingGame = resultingGame.copyWith(unhandledEvents: unhandledEvents.append(reactionResult).toList());
        } else if (reactionResult is Game) {
          resultingGame = reactionResult;
        } else {
          throw UnsupportedError("When calling applyer on reaction in rule, the returned type was '${reactionResult.runtimeType}'.");
        }
        ruleReactions.removeAt(0);
      } else {
        final owner = playerReactionPairs[0].$1;
        dynamic reactionResult = playerReactionPairs[0].$2.applyer(event, resultingGame, owner);
        if (reactionResult == null) {
        } else if (reactionResult is Player || reactionResult is InputHandler) {
          if (reactionResult is InputHandler) {
            // If input handler, what we actually change are the player, so use the logic for that.
            reactionResult = owner.copyWith(unhandledInputHandlers: owner.unhandledInputHandlers.append(reactionResult).toList());
          }
          final newPlayers = [
            ...resultingGame.players,
          ];
          newPlayers[newPlayers.indexWhere(((player) => player.configuration.id == owner.configuration.id))] = reactionResult;
          resultingGame = resultingGame.copyWith(players: newPlayers);
        } else if (reactionResult is Game) {
          resultingGame = reactionResult;
        } else {
          throw UnsupportedError("When calling applyer on reaction in role owned by '${owner.configuration.name}', the returned type was '${reactionResult.runtimeType}'.");
        }
        playerReactionPairs.removeAt(0);
      }
      _runUntilInput();
    }
    return resultingGame;
  }

  Game applyInput(NetworkMessage input) {
    return this;
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
      return copyWith(isNight: false).applyEvent(Event(type: EventType.dayBegins));
    }
    return null;
  }
}
