import 'package:flutter/material.dart';
import 'package:vampulv/game.dart';

// Handle user input in two steps. Firstly, this class is responsible for showing the widget that a user can interact with, and that widget is responsible for sending a network message message when the input is choosen. This is only done for the player whose input is desired. Secondly, this class handles the resulting network message and apply it to the world. This is done on all devices.
class InputHandler {
  Widget widget;
  Game Function(Game world, String result) resultApplyer;

  InputHandler({
    required this.resultApplyer,
    required this.widget,
  });
}
