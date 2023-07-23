import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../input_handlers/input_handler.dart';
import '../network/message_bodies/propose_lynching_body.dart';
import '../network/message_bodies/set_done_lynching_body.dart';
import '../network/network_message.dart';
import '../network/network_message_type.dart';
import '../utility/loggers.dart';
import '../utility/summarize_difference_jsons.dart';
import 'event.dart';
import 'game_configuration.dart';
import 'log_entry.dart';
import 'player.dart';
import 'player_input.dart';
import 'role.dart';
import 'rule.dart';
import 'saved_game.dart';
import 'serializable_random.dart';
import 'standard_events.dart';
import 'standard_rules.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// A position in a game of vampulv. A list of events and a configuration should be enough to recreate a game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required GameConfiguration configuration,
    required SerializableRandom randomGenerator,
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

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  factory Game.fromConfiguration(GameConfiguration configuration) {
    assert(configuration.problems.isEmpty);
    final randomGenerator = SerializableRandom(configuration.randomSeed);

    // Shuffle the roles while guaranteeing that the forced roles will be used
    final shuffledOrdinaryRoles = configuration.ordinaryRoles.randomize(randomGenerator).toList();
    final ordinaryRolesUsed = configuration.players.length * configuration.rolesPerPlayer - configuration.forcedRoles.length;
    final allRolesShuffled = configuration.forcedRoles
        .followedBy(shuffledOrdinaryRoles.take(ordinaryRolesUsed))
        .randomize(randomGenerator)
        .followedBy(shuffledOrdinaryRoles.skip(ordinaryRolesUsed))
        .map((roleType) => roleType.produceRole())
        .toList();

    // Give every role an image. Every image for a specific role is used the same number of times, except for some which are used once more than the rest. Which these images are are randomized.
    for (final roleOfType in allRolesShuffled.groupBy((role) => role.type)) {
      List<int> usedOnceLess = [];
      for (final role in roleOfType) {
        if (usedOnceLess.isEmpty) {
          usedOnceLess = List.generate(roleOfType.key.imageVariations, (i) => i);
        }
        role.image = usedOnceLess[randomGenerator.nextInt(usedOnceLess.length)];
        usedOnceLess.remove(role.image);
      }
    }

    // Create the players with the shuffled roles
    final players = <Player>[];
    for (int i = 0; i < configuration.players.length; i++) {
      players.add(Player(
        configuration: configuration.players[i],
        roles: allRolesShuffled.sublist(
          configuration.rolesPerPlayer * i,
          configuration.rolesPerPlayer * (i + 1),
        ),
        maxLives: configuration.maxLives,
        lives: configuration.maxLives,
      ));
    }

    // Start the first night and return the game
    return Game(
      configuration: configuration,
      randomGenerator: randomGenerator,
      players: players,
      rolesInDeck: allRolesShuffled.skip(configuration.forcedRoles.length + ordinaryRolesUsed).toList(),
      rules: allRolesShuffled
          .map((role) => role.type)
          .distinct()
          .map((role) => role.produceRule())
          .nonNulls
          .append(StandardRule())
          .append(NightSummaryRule())
          .toList(),
    ) //
        ._runUntilInput()
        .applyEvent(GameBeginsEvent())
        .applyEvent(NightBeginsEvent());
  }

  factory Game.fromSavedGame(SavedGame savedGame) => Game.fromConfiguration(savedGame.configuration).applyNetworkMessages(savedGame.events);

  Game applyNetworkMessages(List<NetworkMessage> messages) {
    Game newGame = this;
    for (final message in messages.orderBy((message) => message.timestamp)) {
      if (!message.type.isGameChange) continue;
      if (message.type == NetworkMessageType.inputToGame) {
        newGame = newGame.applyInput(PlayerInput.fromJson(message.body));
      } else if (message.type == NetworkMessageType.proposeLynching) {
        newGame = newGame.applyEvent(ProposeLynchingEvent.fromBody((ProposeLynchingBody.fromJson(message.body))));
      } else if (message.type == NetworkMessageType.doneLynching) {
        final body = SetDoneLynchingBody.fromJson(message.body);
        newGame = newGame.copyWithPlayer(newGame.playerFromId(body.playerId).copyWith(lynchingDone: body.value))._runUntilInput();
      } else {
        throw UnimplementedError("Cannot yet handle network messages of type '${message.type.name}'.");
      }
    }
    Loggers.game.fine(() => 'NetworkMessages applied. Diff in game:\n${summaryObjectDiff(this, newGame)}');
    return newGame;
  }

  Game applyEvent(Event event) {
    return _applyEventOnly(event)._runUntilInput();
  }

  Game applyInput(PlayerInput input) {
    final caller = playerFromId(input.ownerId);
    final inputHandler = caller.currentInputHandler;
    // If the input is invalid we silently ignore it.
    if (inputHandler == null || //
        input.playerInputNumber != caller.handledInputs) return this;
    final result = _applyResultFromApplyer(inputHandler.resultApplyer(input, this, caller), input.ownerId)
        .game
        .copyWithPlayerModification(
            input.ownerId,
            (player) => player.copyWith(
                  unhandledInputHandlers: player.unhandledInputHandlers.exclude(inputHandler).toList(),
                  handledInputs: player.handledInputs + 1,
                ))
        ._runUntilInput();
    Loggers.game.finer(() => 'Player input applied. Diff in game:\n${summaryObjectDiff(this, result)}');
    return result;
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
    Loggers.game.finer(() => "Event of type '${event.runtimeType}' applied. Diff in game:\n${summaryObjectDiff(this, resultingGame.game)}");
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
    Game? newGame;
    bool canceled = false;
    if (result == null) {
      newGame = this;
    }
    if (result == EventResult.cancel) {
      newGame = this;
      canceled = true;
    }
    if (result is InputHandler) {
      if (callerId == null) {
        throw UnsupportedError('Cannot apply InputHandler without an owner.');
      }
      final caller = playerFromId(callerId);
      newGame = copyWithPlayer(caller.copyWith(unhandledInputHandlers: caller.unhandledInputHandlers.append(result).toList()));
    }
    if (result is Player) {
      newGame = copyWithPlayer(result);
    }
    if (result is String) {
      // If String, what we actually want to do is add a LogEntry.
      result = LogEntry(value: result, playerVisibleTo: callerId);
    }
    if (result is LogEntry) {
      newGame = copyWith(log: log.append(result).toList());
    }
    if (result is Event) {
      if (result.appliedMorning) {
        newGame = copyWith(unhandledEvents: unhandledEvents.append(result).toList());
      } else {
        newGame = applyEvent(result);
      }
    }
    if (result is Game) {
      newGame = result;
    }
    if (result is Iterable && newGame == null) {
      _ApplyResultResult gameSoFar = _ApplyResultResult(this);
      for (final partResult in result) {
        gameSoFar = gameSoFar.game._applyResultFromApplyer(partResult, callerId);
        if (gameSoFar.canceled) break;
      }
      return gameSoFar;
    }
    if (newGame == null) {
      throw UnsupportedError(
          "When applying result ${callerId == null ? 'without an owner' : 'with owner ${playerFromId(callerId).name}'}, the returned type was '${result.runtimeType}'.");
    }
    Loggers.game.finer(() => 'Result from applyer applied. Diff in game:\n${summaryObjectDiff(this, newGame)}');
    return _ApplyResultResult(newGame, canceled: canceled);
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
