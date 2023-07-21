import 'package:flutter/material.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/confirm_child_input_handlers.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/card_turner.dart';
import 'package:vampulv/roles/cupid.dart';
import 'package:vampulv/roles/hoodler.dart';
import 'package:vampulv/roles/hunter.dart';
import 'package:vampulv/roles/priest.dart';
import 'package:vampulv/roles/seer.dart';
import 'package:vampulv/roles/standard_input_handlers.dart';
import 'package:vampulv/roles/vampulv.dart';
import 'package:vampulv/roles/witch.dart';

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

  /// Appears for spectators viewing unhandled input handlers.
  final String description;

  /// Must return something that the game knows what to do with. See Game for more information.
  final dynamic Function(PlayerInput input, Game game, Player owner) resultApplyer;

  InputHandler({
    required this.description,
    required this.resultApplyer,
    required this.widget,
  }) {
    assert(typeOrder.contains(runtimeType), "Cannot instanciate InputHandler of type '$runtimeType' because it is not in the typeOrder field.");
  }
}
