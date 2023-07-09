import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/logentry.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/player_input.dart';
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
    @Default([]) List<LogEntry> log,
    @Default(false) bool isNight,
    @Default(false) bool isFinished,
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

  factory Game.fromNetworkMessages(GameConfiguration configuration, List<NetworkMessage> messages) {
    Game game = Game.fromConfiguration(configuration);
    for (final message in messages) {
      if (!message.type.isGameChange) continue;
      if (message.type == NetworkMessageType.inputToGame) {
        game = game.applyInput(PlayerInput.fromJson(message.body));
      } else {
        throw UnimplementedError("Cannot yet handle network messages of type '${message.type.name}'.");
      }
    }
    return game;
  }

  Game applyEvent(Event event) {
    return _applyEventOnly(event)._runUntilInput();
  }

  Game applyInput(PlayerInput input) {
    return _applyResultFromApplyer(playerFromId(input.ownerId).currentInputHandler!.resultApplyer(input, this, playerFromId(input.ownerId)), input.ownerId);
  }

  Game _applyEventOnly(Event event) {
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
        _applyResultFromApplyer(ruleReactions[0].applyer(event, resultingGame), null);
        ruleReactions.removeAt(0);
      } else {
        final owner = playerReactionPairs[0].$1;
        _applyResultFromApplyer(playerReactionPairs[0].$2.applyer(event, resultingGame, owner), owner.configuration.id);
        playerReactionPairs.removeAt(0);
      }
    }
    return resultingGame;
  }

  /// Valid types for the result
  /// - null to change nothing
  /// - Game to set entire game
  /// - Event to add it to the game
  /// - LogEntry to log it to the game
  /// - String to add a log entry visible to caller if it exists or to everyone otherwise
  /// - Player to set caller
  /// - InputHandler to add an input handler to the caller
  /// - iterable of valid values to set them all in order
  Game _applyResultFromApplyer(dynamic result, int? callerId) {
    if (result == null) {
      return this;
    }
    if (result is InputHandler) {
      if (callerId == null) {
        throw UnsupportedError("Cannot apply InputHandler without an owner.");
      }
      Player caller = playerFromId(callerId);
      // If input handler, what we actually change are the player, so use the logic for that.
      result = caller.copyWith(unhandledInputHandlers: caller.unhandledInputHandlers.append(result).toList());
    }
    if (result is Player) {
      if (callerId == null) {
        throw UnsupportedError("Cannot apply Player without an owner.");
      }
      final newPlayers = [
        ...players,
      ];
      newPlayers[newPlayers.indexWhere(((player) => player.configuration.id == callerId))] = result;
      return copyWith(players: newPlayers);
    }
    if (result is String) {
      // If String, what we actually want to do is add a LogEntry.
      result = LogEntry(value: result, playerVisibleTo: callerId);
    }
    if (result is LogEntry) {
      return copyWith(log: log.append(result).toList());
    }
    if (result is Event) {
      return copyWith(unhandledEvents: unhandledEvents.append(result).toList());
    }
    if (result is Game) {
      return result;
    }
    if (result is Iterable) {
      Game gameSoFar = this;
      for (final partResult in result) {
        gameSoFar = gameSoFar._applyResultFromApplyer(partResult, callerId);
      }
      return gameSoFar;
    }
    throw UnsupportedError("When applying result ${callerId == null ? 'without an owner' : 'with owner ${playerFromId(callerId).configuration.name}'}, the returned type was '${result.runtimeType}'.");
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
    if (isNight && players.every((player) => player.unhandledInputHandlers.isEmpty)) {
      if (unhandledEvents.isEmpty) {
        return copyWith(isNight: false).applyEvent(Event(type: EventType.dayBegins));
      } else {
        return _applyEventOnly(unhandledEvents.min((event1, event2) {
          if (event1.type == event2.type) {
            assert(event1.priority == null || event2.priority == null, "There are more than one unhandled event of type '${event1.type}', and at least one of them has priority null.");
            assert(event1.priority != event2.priority, "There are multiple unhandled events of type '${event1.type}' with the same priority.");
            return event2.priority! - event1.priority!;
          }
          return event1.type.index - event2.type.index;
        }));
      }
    }
    return null;
  }

  Player playerFromId(int id) => players.singleWhere((player) => player.configuration.id == id);
}
