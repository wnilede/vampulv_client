import 'package:flutter/material.dart';

import '../components/confirm_message.dart';
import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/player_input.dart';
import 'input_handler.dart';

class EarlyConfirmChildInputHandler extends _ConfirmChildInputHandler {
  EarlyConfirmChildInputHandler({required super.description, super.onConfirm, required super.child});
  EarlyConfirmChildInputHandler.withText(super.message, {super.onConfirm}) : super.withText();
}

class LateConfirmChildInputHandler extends _ConfirmChildInputHandler {
  LateConfirmChildInputHandler({required super.description, super.onConfirm, required super.child});
  LateConfirmChildInputHandler.withText(super.message, {super.onConfirm}) : super.withText();
}

class _ConfirmChildInputHandler extends InputHandler {
  _ConfirmChildInputHandler({
    required String description,
    dynamic Function(PlayerInput, Game, Player)? onConfirm,
    required Widget child,
  }) : super(
          description: description,
          widget: ConfirmMessage(child: child),
          resultApplyer: onConfirm ?? (input, game, owner) {},
        );

  _ConfirmChildInputHandler.withText(String message, {dynamic Function(PlayerInput, Game, Player)? onConfirm})
      : this(
          description: "Läs meddelande '$message'",
          onConfirm: onConfirm,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
}
