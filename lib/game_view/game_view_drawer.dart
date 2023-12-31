import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cheating_indicator.dart';
import '../network/connected_device_provider.dart';
import 'game_view.dart';

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
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ändra spelare'),
                  CheatingIndicator(),
                ],
              ),
              selected: selected == GameViewSelection.changeControlledPlayer,
              onTap: () {
                onSelect(GameViewSelection.changeControlledPlayer);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ändra spel'),
              selected: selected == GameViewSelection.changeGame,
              onTap: () {
                onSelect(GameViewSelection.changeGame);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
