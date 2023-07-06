import 'package:flutter/material.dart';
import 'package:vampulv/game_view/change_controlled_player.dart';
import 'package:vampulv/game_view/do_input.dart';
import 'package:vampulv/game_view/information.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  _GameView view = _GameView.input;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Vampulv'),
              ),
              ListTile(
                title: const Text('Game'),
                selected: view == _GameView.input,
                onTap: () {
                  changeView(_GameView.input);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Information'),
                selected: view == _GameView.aboutGame,
                onTap: () {
                  changeView(_GameView.aboutGame);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Ändra spelare'),
                selected: view == _GameView.changeControlledPlayer,
                onTap: () {
                  changeView(_GameView.changeControlledPlayer);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: switch (view) {
          _GameView.input => const DoInput(),
          _GameView.changeControlledPlayer => const ChangeControlledPlayer(),
          _GameView.aboutGame => const Information(),
        },
      );

  void changeView(_GameView view) {
    if (this.view == view) return;
    setState(() {
      this.view = view;
    });
  }
}

enum _GameView {
  input,
  changeControlledPlayer,
  aboutGame,
}
