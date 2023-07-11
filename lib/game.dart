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
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_rules.dart';
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
            .map((roleType) => roleType.produceRole())
            .toList(),
        lives: configuration.maxLives,
      ));
    }
    return Game(
      randomGenerator: randomGenerator,
      players: players,
      rules: configuration.roles //
          .distinct()
          .map((role) => role.produceRule())
          .nonNulls
          .append(StandardRule())
          .toList(),
    ) //
        ._runUntilInput()
        .applyEvent(Event(type: EventType.gameBegins))
        .applyEvent(Event(type: EventType.nightBegins));
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
    final caller = playerFromId(input.ownerId);
    return _applyResultFromApplyer(caller.currentInputHandler!.resultApplyer(input, this, caller), input.ownerId)
        .game //
        .copyWithPlayer(caller.removeCurrentInputHandler);
  }

  Game _applyEventOnly(Event event) {
    final ruleReactions = rules
        .map(
          (rule) => rule.reactions,
        )
        .flatten()
        .where((rule) => rule.filter == event.type || rule.filter == null)
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
        .where((playerReaction) => playerReaction.$2.filter == event.type || playerReaction.$2.filter == null)
        .orderBy((playerReaction) => playerReaction.$2.priority)
        .toList();
    _ApplyResultResult resultingGame = _ApplyResultResult(this);
    while ((ruleReactions.isNotEmpty || playerReactionPairs.isNotEmpty) && !resultingGame.canceled) {
      if (playerReactionPairs.isEmpty || ruleReactions.isNotEmpty && ruleReactions[0].priority > playerReactionPairs[0].$2.priority) {
        resultingGame = resultingGame.game._applyResultFromApplyer(ruleReactions[0].applyer(event, resultingGame.game), null);
        ruleReactions.removeAt(0);
      } else {
        final owner = playerReactionPairs[0].$1;
        resultingGame = resultingGame.game._applyResultFromApplyer(playerReactionPairs[0].$2.applyer(event, resultingGame.game, owner), owner.configuration.id);
        playerReactionPairs.removeAt(0);
      }
    }
    return resultingGame.game;
  }

  /// Valid types for the result
  /// - null to change nothing
  /// - Game to set entire game
  /// - Event to add it to the game
  /// - LogEntry to log it to the game
  /// - String to add a log entry visible to caller if it exists or to everyone otherwise
  /// - Player to set caller
  /// - InputHandler to add an input handler to the caller
  /// - EventResult.cancel to cancel the event and stop evaluating reactions for it
  /// - iterable of valid values to set them all in order
  ///
  /// Returns the new game and whether the event was cancelled.
  _ApplyResultResult _applyResultFromApplyer(dynamic result, int? callerId) {
    if (result == null) {
      return _ApplyResultResult(this);
    }
    if (result == EventResult.cancel) {
      return _ApplyResultResult(this, canceled: false);
    }
    if (result is InputHandler) {
      if (callerId == null) {
        throw UnsupportedError('Cannot apply InputHandler without an owner.');
      }
      final caller = playerFromId(callerId);
      return _ApplyResultResult(copyWithPlayer(caller.copyWith(unhandledInputHandlers: caller.unhandledInputHandlers.append(result).toList())));
    }
    if (result is Player) {
      if (callerId == null) {
        throw UnsupportedError('Cannot apply Player without an owner.');
      }
      return _ApplyResultResult(copyWithPlayer(result));
    }
    if (result is String) {
      // If String, what we actually want to do is add a LogEntry.
      result = LogEntry(value: result, playerVisibleTo: callerId);
    }
    if (result is LogEntry) {
      return _ApplyResultResult(copyWith(log: log.append(result).toList()));
    }
    if (result is Event) {
      return _ApplyResultResult(copyWith(unhandledEvents: unhandledEvents.append(result).toList()));
    }
    if (result is Game) {
      return _ApplyResultResult(result);
    }
    if (result is Iterable) {
      _ApplyResultResult gameSoFar = _ApplyResultResult(this);
      for (final partResult in result) {
        gameSoFar = gameSoFar.game._applyResultFromApplyer(partResult, callerId);
        if (gameSoFar.canceled) break;
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

  Game copyWithPlayer(Player player) {
    final newPlayers = [
      ...players,
    ];
    newPlayers[players.indexWhere((existingPlayer) => existingPlayer.configuration.id == player.configuration.id)] = player;
    return copyWith(players: newPlayers);
  }
}

@freezed
class _ApplyResultResult with _$_ApplyResultResult {
  factory _ApplyResultResult(Game game, {@Default(false) bool canceled}) = __ApplyResultResult;
}
