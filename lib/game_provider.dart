import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:vampulv/synchronized_data/synchronized_data_provider.dart';
import 'package:xrandom/xrandom.dart';

class GameNotifier extends StateNotifier<Game?> {
  GameNotifier() : super(null);

  void applyEvent(NetworkMessage event) {
    state = state?.applyChange(event);
  }

  void recreateGame(GameConfiguration gameConfiguration, List<NetworkMessage> gameEvents) {
    state = Game(
      randomGenerator: Xorshift32(gameConfiguration.randomSeed),
      players: gameConfiguration.players
          .map((playerConfiguration) => Player(
                configuration: playerConfiguration,
                lives: gameConfiguration.maxLives,
                roles: [],
              ))
          .toList(),
    );
  }

  set game(Game? game) {
    state = game;
  }
}

final StateNotifierProvider<GameNotifier, Game?> gameProvider = StateNotifierProvider<GameNotifier, Game?>((ref) {
  if (!ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameHasBegun))) {
    return GameNotifier();
  }
  GameNotifier notifier = GameNotifier();
  notifier.recreateGame(
    ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration)),
    ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameEvents)),
  );
  return notifier;
});
