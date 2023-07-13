import 'package:flutter/material.dart';
import 'package:vampulv/confirm_message.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';

class EarlyConfirmChildInputHandler extends _ConfirmChildInputHandler {
  EarlyConfirmChildInputHandler({required super.description, required super.identifier, required super.child});
  EarlyConfirmChildInputHandler.withText(super.message) : super.withText();
}

class LateConfirmChildInputHandler extends _ConfirmChildInputHandler {
  LateConfirmChildInputHandler({required super.description, required super.identifier, required super.child});
  LateConfirmChildInputHandler.withText(super.message) : super.withText();
}

class _ConfirmChildInputHandler extends InputHandler {
  _ConfirmChildInputHandler({required String description, required String identifier, required Widget child})
      : super(
          description: description,
          identifier: 'confirm-child-$identifier',
          widget: ConfirmMessage(inputIdentifier: 'confirm-child-$identifier', child: child),
          resultApplyer: (PlayerInput input, Game game, Player owner) {},
        );

  _ConfirmChildInputHandler.withText(String message)
      : this(
          description: "Läs meddelande '$message'",
          identifier: 'text-${message.toLowerCase().replaceAll(RegExp(r'[^a-zåäö ]'), '').trim().replaceAll(RegExp(r' +'), '-')}',
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
