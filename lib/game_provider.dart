import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

class GameNotifier extends StateNotifier<Game?> {
  GameNotifier() : super(null);

  void applyInput(PlayerInput input) {
    state = state?.applyInput(input);
  }

  void recreateGame(GameConfiguration gameConfiguration, List<NetworkMessage> gameEvents) {
    state = Game.fromNetworkMessages(gameConfiguration, gameEvents);
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
