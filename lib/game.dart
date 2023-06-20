import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/synchronized_data/network_message.dart';

part 'game.freezed.dart';
part 'game.g.dart';

// A game of vampulv. The list of events chould be enough to recreate the game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required List<Player> users,
    required List<NetworkMessage> events,
    required bool started,
  }) = _Game;
  factory Game.fromJson(Map<String, Object?> json) => _$GameFromJson(json);
  const Game._();

  Game applyChange(NetworkMessage change) {
    return copyWith(events: [
      ...events,
      change,
    ]);
  }
}
