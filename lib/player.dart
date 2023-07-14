import 'package:darq/darq.dart';
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
    required int maxLives,
    @Default([]) List<InputHandler> unhandledInputHandlers,
    @Default(false) bool isWinner,
    @Default(true) bool alive,
    bool? lynchingVote,
    @Default(1) int votesInLynching,
    @Default([]) List<int> previouslyProposed,
    @Default(false) bool lynchingDone,
    @Default(0) int handledInputs,
  }) = _Player;

  const Player._();

  InputHandler? get currentInputHandler => unhandledInputHandlers.isEmpty
      ? null
      : unhandledInputHandlers.min(
          (handler1, handler2) => InputHandler.typeOrder.indexOf(handler1.runtimeType) - InputHandler.typeOrder.indexOf(handler2.runtimeType),
        );
  int get id => configuration.id;
  String get name => configuration.name;
}
