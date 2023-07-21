import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'create_game_view.dart';

class LobbyDrawer extends ConsumerWidget {
  final CreateGameViewSelection selected;
  final void Function(CreateGameViewSelection) onSelect;

  const LobbyDrawer({
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
            ListTile(
              title: const Text('Ställ in spel'),
              selected: selected == CreateGameViewSelection.lobby,
              onTap: () {
                onSelect(CreateGameViewSelection.lobby);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Byt spel'),
              selected: selected == CreateGameViewSelection.changeGame,
              onTap: () {
                onSelect(CreateGameViewSelection.changeGame);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
