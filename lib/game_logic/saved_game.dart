import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_logic/game_configuration.dart';
import 'package:vampulv/network/network_message.dart';

part 'saved_game.freezed.dart';
part 'saved_game.g.dart';

/// Everything needed to recreate a game from scratch.
@freezed
class SavedGame with _$SavedGame {
  factory SavedGame({
    required GameConfiguration configuration, // Are sent as a whole by clients.
    @Default([]) List<NetworkMessage> events, // Are sent one event at a time.
    @Default(false) bool hasBegun, // Are only sent as a part of a whole SynchronizedData object.
  }) = _SavedGame;

  factory SavedGame.fromJson(Map<String, dynamic> json) => _$SavedGameFromJson(json);
}
