import 'package:flutter/material.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';

// Handle user input in two steps. Firstly, this class is responsible for showing the widget that a user can interact with, and that widget is responsible for sending a network message message when the input is choosen. This is only done for the player whose input is desired. Secondly, this class handles the resulting network message and apply it to the world. This is done on all devices.
class InputHandler {
  Widget widget;

  /// Must return something that the game knows what to do with. See Game for more information.
  dynamic Function(PlayerInput input, Game game, Player owner) resultApplyer;

  InputHandler({
    required this.resultApplyer,
    required this.widget,
  });

  static InputHandler confirmChild(Widget child) => InputHandler(
        widget: child,
        resultApplyer: (PlayerInput input, Game game, Player owner) {},
      );
  static InputHandler confirmMessage(String message) => InputHandler.confirmChild(Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ));
}
