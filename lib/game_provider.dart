import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

part 'game_provider.g.dart';

@riverpod
class CurrentGame extends _$CurrentGame {
  @override
  Game? build() {
    if (!ref.watch(currentSynchronizedDataProvider.select((synchronizedData) => synchronizedData.gameHasBegun))) {
      return null;
    }
    return Game.fromNetworkMessages(
      ref.watch(currentSynchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration)),
      ref.watch(currentSynchronizedDataProvider.select((synchronizedData) => synchronizedData.gameEvents)),
    );
  }

  void applyInput(PlayerInput input) {
    state = state?.applyInput(input);
  }

  void recreateGame(GameConfiguration gameConfiguration, List<NetworkMessage> gameEvents) {
    state = Game.fromNetworkMessages(gameConfiguration, gameEvents);
  }

  int hej() => 4;

  void game(Game? game) {
    state = game;
  }
}
