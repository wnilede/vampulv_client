import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_view/game_view.dart';
import 'package:vampulv/network/connected_device_provider.dart';

class GameViewDrawer extends ConsumerWidget {
  final GameViewSelection selected;
  final void Function(GameViewSelection) onSelect;

  const GameViewDrawer({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 170,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text('Vampulv'),
            ),
            if (ref.watch(controlledPlayerProvider) != null)
              ListTile(
                title: const Text('Game'),
                selected: selected == GameViewSelection.input,
                onTap: () {
                  onSelect(GameViewSelection.input);
                  Navigator.pop(context);
                },
              ),
            if (ref.watch(controlledPlayerProvider) == null)
              ListTile(
                title: const Text('Att göra-listor'),
                selected: selected == GameViewSelection.spectatorOverview,
                onTap: () {
                  onSelect(GameViewSelection.spectatorOverview);
                  Navigator.pop(context);
                },
              ),
            ListTile(
              title: const Text('Information'),
              selected: selected == GameViewSelection.aboutGame,
              onTap: () {
                onSelect(GameViewSelection.aboutGame);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Historik'),
              selected: selected == GameViewSelection.log,
              onTap: () {
                onSelect(GameViewSelection.log);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ändra spelare'),
              selected: selected == GameViewSelection.changeControlledPlayer,
              onTap: () {
                onSelect(GameViewSelection.changeControlledPlayer);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
