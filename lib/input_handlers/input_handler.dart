import 'package:flutter/material.dart';
import 'package:vampulv/confirm_message.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';

// Handle user input in two steps. Firstly, this class is responsible for showing the widget that a user can interact with, and that widget is responsible for sending a network message message when the input is choosen. This is only done for the player whose input is desired. Secondly, this class handles the resulting network message and apply it to the world. This is done on all devices.
class InputHandler {
  Widget widget;

  /// Appears for spectators viewing unhandled input handlers.
  String description;

  /// Typically a constant for a particular type of input.
  ///
  /// Used together with the owning player to identify which InputHandler are responsible for handling the PlayerInput sent. As such, it must be the same for all clients. To minimize invalidation of PlayerInput when another message is sent with earlier timestamp, it should preferably be the same even if an unrelated message is added before. Other than that it should be as unique as possible, so the game can detect when the input should actually be invalidated.
  ///
  /// To prevent crashes, the resultApplyer of one input handler should not throw if feed the PlayerInput of another input handler with the same owner and identifier.
  String identifier;

  /// Must return something that the game knows what to do with. See Game for more information.
  dynamic Function(PlayerInput input, Game game, Player owner) resultApplyer;

  InputHandler({
    required this.description,
    required this.identifier,
    required this.resultApplyer,
    required this.widget,
  });

  static InputHandler confirmChild({required String description, required String identifier, required Widget child}) => InputHandler(
        description: description,
        identifier: 'confirm-child-$identifier',
        widget: ConfirmMessage(inputIdentifier: 'confirm-child-$identifier', child: child),
        resultApplyer: (PlayerInput input, Game game, Player owner) {},
      );
  static InputHandler confirmMessage(String message) => InputHandler.confirmChild(
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
