import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_logic/saved_game.dart';

part 'saved_games_list.freezed.dart';
part 'saved_games_list.g.dart';

@freezed
class SavedGamesList with _$SavedGamesList {
  factory SavedGamesList({
    @Default({}) Map<String, SavedGame> games,
  }) = _SavedGamesList;

  factory SavedGamesList.fromJson(Map<String, dynamic> json) => _$SavedGamesListFromJson(json);
}
