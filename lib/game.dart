import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/network/message_bodies/propose_lynching_body.dart';
import 'package:vampulv/network/message_bodies/set_done_lynching_body.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/roles/standard_rules.dart';
import 'package:xrandom/xrandom.dart';

part 'game.freezed.dart';

/// A position in a game of vampulv. A list of events and a configuration should be enough to recreate a game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required GameConfiguration configuration,
    required Xorshift32 randomGenerator,
    required List<Player> players,
    required List<Role> rolesInDeck,
    @Default([]) List<Rule> rules,
    @Default([]) List<Event> unhandledEvents,
    @Default([]) List<LogEntry> log,
    @Default(false) bool isNight,
    @Default(false) bool isFinished,
    @Default(0) int dayNumber,
  }) = _Game;

  const Game._();

  factory Game.fromConfiguration(GameConfiguration configuration) {
    assert(configuration.roles.length >= configuration.players.length * configuration.rolesPerPlayer,
        'There are not enough roles for all players.');
    final randomGenerator = Xorshift32(configuration.randomSeed);
    final players = <Player>[];
    final shuffledRoles = configuration.roles.map((roleType) => roleType.produceRole()).randomize(randomGenerator).toList();

    // Every image for a specific role is used the same number of times, except for some which are used once more than the rest. Which these images are is randomized.
    for (final roleOfType in shuffledRoles.groupBy((role) => role.type)) {
      List<int> usedOnceLess = [];
      for (final role in roleOfType) {
        if (usedOnceLess.isEmpty) {
          usedOnceLess = List.generate(roleOfType.key.imageVariations, (i) => i);
        }
        role.image = usedOnceLess[randomGenerator.nextInt(usedOnceLess.length)];
        usedOnceLess.remove(role.image);
      }
    }

    for (int i = 0; i < configuration.players.length; i++) {
      players.add(Player(
        configuration: configuration.players[i],
        roles: shuffledRoles
            .sublist(
              configuration.rolesPerPlayer * i,
              configuration.rolesPerPlayer * (i + 1),
            )
            .toList(),
        maxLives: configuration.maxLives,
        lives: configuration.maxLives,
      ));
    }
    return Game(
      configuration: configuration,
      randomGenerator: randomGenerator,
      players: players,
      rolesInDeck: shuffledRoles.sublist(configuration.rolesPerPlayer * configuration.players.length),
      rules: configuration.roles //
          .distinct()
          .map((role) => role.produceRule())
          .nonNulls
          .append(StandardRule())
          .toList(),
    ) //
        ._runUntilInput()
        .applyEvent(GameBeginsEvent())
        .applyEvent(NightBeginsEvent());
  }

  factory Game.fromNetworkMessages(GameConfiguration configuration, List<NetworkMessage> messages) {
    Game game = Game.fromConfiguration(configuration);
    for (final message in messages.orderBy((message) => message.timestamp)) {
      if (!message.type.isGameChange) continue;
      if (message.type == NetworkMessageType.inputToGame) {
        game = game.applyInput(PlayerInput.fromJson(message.body));
      } else if (message.type == NetworkMessageType.proposeLynching) {
        game = game.applyEvent(ProposeLynchingEvent.fromBody((ProposeLynchingBody.fromJson(message.body))));
      } else if (message.type == NetworkMessageType.doneLynching) {
        final body = SetDoneLynchingBody.fromJson(message.body);
        game = game.copyWithPlayer(game.playerFromId(body.playerId).copyWith(lynchingDone: body.value))._runUntilInput();
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
    final inputHandler = caller.currentInputHandler;
    // If the input is invalid we silently ignore it.
    if (inputHandler == null || //
        inputHandler.identifier != input.identifier ||
        input.playerInputNumber != caller.handledInputs) return this;
    return _applyResultFromApplyer(inputHandler.resultApplyer(input, this, caller), input.ownerId)
        .game
        .copyWithPlayerModification(
            input.ownerId,
            (player) => player.copyWith(
                  unhandledInputHandlers: player.unhandledInputHandlers.exclude(inputHandler).toList(),
                  handledInputs: player.handledInputs + 1,
                ))
        ._runUntilInput();
  }

  Game _applyEventOnly(Event event) {
    final ruleReactions = rules
        .map(
          (rule) => rule.reactions,
        )
        .flatten()
        .where((rule) => rule.passesFilter(event))
        .orderByDescending((reaction) => reaction.priority)
        .toList();
    final playerReactionPairs = players
        .map(
          (player) => player.roles //
              .map((role) => role.reactions)
              .flatten()
              .where((reaction) => reaction.passesFilter(event) && (player.alive || reaction.worksAfterDeath))
              .map(
                (reaction) => (
                  player.id,
                  reaction,
                ),
              ),
        )
        .flatten()
        .orderByDescending((playerReaction) => playerReaction.$2.priority)
        .toList();
    _ApplyResultResult resultingGame = _ApplyResultResult(this);
    while ((ruleReactions.isNotEmpty || playerReactionPairs.isNotEmpty) && !resultingGame.canceled) {
      if (playerReactionPairs.isEmpty || ruleReactions.isNotEmpty && ruleReactions[0].priority > playerReactionPairs[0].$2.priority) {
        resultingGame = resultingGame.game._applyResultFromApplyer(ruleReactions[0].apply(event, resultingGame.game), null);
        ruleReactions.removeAt(0);
      } else {
        resultingGame = resultingGame.game._applyResultFromApplyer(
          playerReactionPairs[0].$2.apply(event, resultingGame.game, resultingGame.game.playerFromId(playerReactionPairs[0].$1)),
          playerReactionPairs[0].$1,
        );
        playerReactionPairs.removeAt(0);
      }
    }
    print("Event '${event.runtimeType}' applied");
    return resultingGame.game;
  }

  /// Valid types for the result
  /// - null to change nothing
  /// - Game to set entire game
  /// - Event to add it to the game
  /// - LogEntry to log it to the game
  /// - String to add a log entry visible to caller if it exists or to everyone otherwise
  /// - Player to set the player with that id
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
      return _ApplyResultResult(this, canceled: true);
    }
    if (result is InputHandler) {
      if (callerId == null) {
        throw UnsupportedError('Cannot apply InputHandler without an owner.');
      }
      final caller = playerFromId(callerId);
      return _ApplyResultResult(copyWithPlayer(caller.copyWith(unhandledInputHandlers: caller.unhandledInputHandlers.append(result).toList())));
    }
    if (result is Player) {
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
      if (result.appliedMorning) {
        return _ApplyResultResult(copyWith(unhandledEvents: unhandledEvents.append(result).toList()));
      } else {
        return _ApplyResultResult(applyEvent(result));
      }
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
    throw UnsupportedError(
        "When applying result ${callerId == null ? 'without an owner' : 'with owner ${playerFromId(callerId).name}'}, the returned type was '${result.runtimeType}'.");
  }

  Game _runUntilInput() {
    Game oldResult = this;
    while (true) {
      final result = oldResult._runOneStep();
      // We only check for cycles of length 1. That should be enough for most cases, and it is neccessary in some. But I could imagine it happening in some weird edge case that we get in a longer cycle. To prevent this, we could keep track of and compare to all previous states, but that might not be enough, if the cycle for example increase dayNumber.
      if (result == null || result == oldResult) {
        if (isFinished) {
          return oldResult._applyEventOnly(EndScoringEvent());
        }
        return oldResult;
      } else {
        oldResult = result;
      }
    }
  }

  Game? _runOneStep() {
    if (isNight && players.every((player) => player.unhandledInputHandlers.isEmpty)) {
      if (unhandledEvents.isEmpty) {
        return _applyEventOnly(DayBeginsEvent());
      } else {
        Event eventToApply = unhandledEvents.min(
          (event1, event2) =>
              Event.typeOrder.indexWhere((subType) => event1.runtimeType == subType) -
              Event.typeOrder.indexWhere((subType) => event2.runtimeType == subType),
        );
        Game afterEvent = _applyEventOnly(eventToApply);
        return afterEvent.copyWith(unhandledEvents: afterEvent.unhandledEvents.exclude(eventToApply).toList());
      }
    }
    if (!isNight && alivePlayers.every((player) => player.lynchingDone)) {
      return _applyEventOnly(NightBeginsEvent());
    }
    return null;
  }

  Player playerFromId(int id) => players.singleWhere((player) => player.id == id);

  Game copyWithPlayer(Player player) {
    final newPlayers = [
      ...players,
    ];
    newPlayers[players.indexWhere((existingPlayer) => existingPlayer.id == player.id)] = player;
    return copyWith(players: newPlayers);
  }

  Game copyWithPlayerModification(int playerId, Player Function(Player) modification) {
    return copyWithPlayer(modification(playerFromId(playerId)));
  }

  List<Player> get alivePlayers => players.where((player) => player.alive).toList();
}

@freezed
class _ApplyResultResult with _$_ApplyResultResult {
  factory _ApplyResultResult(Game game, {@Default(false) bool canceled}) = __ApplyResultResult;
}
