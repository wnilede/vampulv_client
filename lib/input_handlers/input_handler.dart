import 'package:flutter/material.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/card_turner.dart';
import 'package:vampulv/roles/seer.dart';
import 'package:vampulv/roles/standard_input_handlers.dart';
import 'package:vampulv/roles/vampulv.dart';

/// Handle user input in two steps. Firstly, this class is responsible for showing the widget that a user can interact with, and that widget is responsible for sending a network message message when the input is choosen. This is only done for the player whose input is desired. Secondly, this class handles the resulting network message and apply it to the world. This is done on all devices.
abstract class InputHandler {
  /// Determines in which order InputHandlers of different types are evaluated. Input handlers of the same type are evaluated in the order they were added to the player.
  static const typeOrder = [
    EarlyConfirmChildInputHandler,
    CardTurnerObservedInputHandler,
    LynchingVoteInputHandler,
    VampulvTargetInputHandler,
    VampulvBlockingInputHandler,
    SeerTargetInputHandler,
    CardTurnerObserverInputHandler,
    LynchingWaitingResultInputHandler,
    LateConfirmChildInputHandler,
  ];

  final Widget widget;

  /// Appears for spectators viewing unhandled input handlers.
  final String description;

  /// Typically a constant for a particular type of input.
  ///
  /// Used together with the owning player to identify which InputHandler are responsible for handling the PlayerInput sent. As such, it must be the same for all clients. To minimize invalidation of PlayerInput when another message is sent with earlier timestamp, it should preferably be the same even if an unrelated message is added before. Other than that it should be as unique as possible, so the game can detect when the input should actually be invalidated.
  ///
  /// To prevent crashes, the resultApplyer of one input handler should not throw if feed the PlayerInput of another input handler with the same owner and identifier.
  final String identifier;

  /// Must return something that the game knows what to do with. See Game for more information.
  final dynamic Function(PlayerInput input, Game game, Player owner) resultApplyer;

  InputHandler({
    required this.description,
    required this.identifier,
    required this.resultApplyer,
    required this.widget,
  }) {
    assert(typeOrder.contains(runtimeType), "Cannot instanciate InputHandler of type '$runtimeType' because it is not in the typeOrder field.");
  }
}
