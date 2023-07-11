import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/roles/role.dart';

part 'player.freezed.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required PlayerConfiguration configuration,
    required List<Role> roles,
    required int lives,
    @Default([]) List<InputHandler> unhandledInputHandlers,
    @Default(false) bool isWinner,
  }) = _Player;

  const Player._();

  bool get alive => lives > 0;
  InputHandler? get currentInputHandler => unhandledInputHandlers.firstOrNull;
  Player get removeCurrentInputHandler => copyWith(unhandledInputHandlers: unhandledInputHandlers.skip(1).toList());
}
