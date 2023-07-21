import 'package:flutter/material.dart';
import '../global_settings/global_settings.dart';
import 'lobby.dart';
import 'lobby_drawer.dart';

class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  CreateGameViewSelection view = CreateGameViewSelection.lobby;

  @override
  Widget build(BuildContext context) {
    final Widget drawer = LobbyDrawer(
      selected: view,
      onSelect: (value) {
        if (view == value) return;
        setState(() {
          view = value;
        });
      },
    );
    return switch (view) {
      CreateGameViewSelection.lobby => Lobby(drawer: drawer),
      CreateGameViewSelection.changeGame => GlobalSettings(drawer: drawer),
    };
  }
}

enum CreateGameViewSelection {
  lobby,
  changeGame,
}
