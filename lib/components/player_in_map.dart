import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_logic/player.dart';
import '../network/connected_device_provider.dart';
import 'context_aware_text.dart';
import 'player_summary.dart';

class PlayerInMap extends ConsumerWidget {
  final Player player;
  final SelectedLevel selectedLevel;
  final void Function()? onSelect;
  final String? reasonForbidden;

  const PlayerInMap(this.player, {required this.selectedLevel, this.reasonForbidden, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpectator = ref.watch(controlledPlayerProvider.select((player) => player == null));
    Color textColor = player.alive ? Colors.black : Colors.white;
    return Material(
      shape: const CircleBorder(),
      color: switch (selectedLevel) {
        SelectedLevel.selected => Colors.orange[700],
        SelectedLevel.selectable => Colors.orange[400],
        SelectedLevel.selectableButMax => const Color.fromARGB(255, 206, 161, 94),
        SelectedLevel.forbidden => const Color.fromARGB(255, 245, 198, 128),
      },
      child: InkWell(
        onLongPress: isSpectator
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => Scaffold(
                          appBar: AppBar(title: Text(player.name)),
                          body: PlayerSummary(player),
                        )),
                  ),
                );
              }
            : null,
        onTap: selectedLevel == SelectedLevel.selectable || selectedLevel == SelectedLevel.selected
            ? onSelect
            : () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: ContextAwareText(reasonForbidden ?? selectedLevel.presentableReason),
                ));
              },
        borderRadius: BorderRadius.circular(100),
        child: FractionallySizedBox(
          widthFactor: math.sqrt1_2,
          heightFactor: math.sqrt1_2,
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  child: Text(
                    player.name,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(math.max(player.lives, 0), (index) => Icon(Icons.favorite, color: textColor)),
                    ...List.generate(
                        math.max(player.maxLives - math.max(player.lives, 0), 0), (index) => Icon(Icons.favorite_border, color: textColor)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum SelectedLevel {
  selected('Spelaren är redan vald.'),
  selectable('Du kan välja spelaren.'),
  selectableButMax('Du kan inte välja fler spelare.'),
  forbidden('Du kan inte välja denna spelare.');

  final String presentableReason;

  const SelectedLevel(this.presentableReason);
}
