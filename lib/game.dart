import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:xrandom/xrandom.dart';

part 'game.freezed.dart';

// A position in a game of vampulv. A list of events and a configuration chould be enough to recreate a game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required Xorshift32 randomGenerator,
    required List<Player> players,
  }) = _Game;

  const Game._();

  Game applyChange(NetworkMessage change) {
    throw UnimplementedError();
  }
}
