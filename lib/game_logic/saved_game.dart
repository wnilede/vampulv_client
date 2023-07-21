import 'package:freezed_annotation/freezed_annotation.dart';

import '../network/network_message.dart';
import 'game_configuration.dart';

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
