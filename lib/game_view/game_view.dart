import 'package:flutter/material.dart';
import 'package:vampulv/game_view/change_controlled_player.dart';
import 'package:vampulv/game_view/do_input.dart';
import 'package:vampulv/game_view/game_view_drawer.dart';
import 'package:vampulv/game_view/information.dart';
import 'package:vampulv/game_view/log_page.dart';
import 'package:vampulv/game_view/spectator_overview.dart';
import 'package:vampulv/global_settings/global_settings.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  GameViewSelection view = GameViewSelection.aboutGame;

  @override
  Widget build(BuildContext context) {
    final Widget drawer = GameViewDrawer(
      selected: view,
      onSelect: (value) {
        if (view == value) return;
        setState(() {
          view = value;
        });
      },
    );
    return switch (view) {
      GameViewSelection.input => DoInput(drawer: drawer),
      GameViewSelection.changeControlledPlayer => ChangeControlledPlayer(drawer: drawer),
      GameViewSelection.aboutGame => Information(drawer: drawer),
      GameViewSelection.log => LogPage(drawer: drawer),
      GameViewSelection.spectatorOverview => SpectatorOverview(drawer: drawer),
      GameViewSelection.changeGame => GlobalSettings(drawer: drawer),
    };
  }
}

enum GameViewSelection {
  input,
  changeControlledPlayer,
  aboutGame,
  log,
  spectatorOverview,
  changeGame,
}
