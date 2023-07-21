import 'package:flutter/material.dart';

import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/player_input.dart';
import '../game_logic/standard_input_handlers.dart';
import '../roles/card_turner.dart';
import '../roles/cupid.dart';
import '../roles/hoodler.dart';
import '../roles/hunter.dart';
import '../roles/priest.dart';
import '../roles/seer.dart';
import '../roles/vampulv.dart';
import '../roles/witch.dart';
import 'confirm_child_input_handlers.dart';

/// Handle user input in two steps. Firstly, this class is responsible for showing the widget that a user can interact with, and that widget is responsible for sending a network message message when the input is choosen. This is only done for the player whose input is desired. Secondly, this class handles the resulting network message and apply it to the world. This is done on all devices.
abstract class InputHandler {
  /// Determines in which order InputHandlers of different types are evaluated. Input handlers of the same type are evaluated in the order they were added to the player.
  static const typeOrder = [
    EarlyConfirmChildInputHandler,
    CardTurnerObservedInputHandler,
    HunterTargetInputHandler,
    HunterBlockingInputHanlder,
    LynchingVoteInputHandler,
    CupidTargetsInputHandler,
    HoodlerTargetsInputHandler,
    VampulvTargetInputHandler,
    VampulvBlockingInputHandler,
    PriestTargetInputHandler,
    SeerTargetInputHandler,
    WitchPoisonInputHandler,
    WitchHealingInputHandler,
    CardTurnerObserverInputHandler,
    LynchingWaitingResultInputHandler,
    LateConfirmChildInputHandler,
  ];

  final Widget widget;

  /// Appears in the appbar when showing the widget.
  final String? title;

  /// Appears for spectators viewing unhandled input handlers.
  final String description;

  /// Must return something that the game knows what to do with. See Game for more information.
  final dynamic Function(PlayerInput input, Game game, Player owner) resultApplyer;

  InputHandler({
    required this.title,
    required this.description,
    required this.resultApplyer,
    required this.widget,
  }) {
    assert(typeOrder.contains(runtimeType), "Cannot instanciate InputHandler of type '$runtimeType' because it is not in the typeOrder field.");
  }
}
