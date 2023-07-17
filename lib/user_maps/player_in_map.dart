import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/player_summary.dart';

class PlayerInMap extends ConsumerWidget {
  final Player player;
  final bool selected;
  final void Function()? onSelect;

  const PlayerInMap(this.player, {this.selected = false, this.onSelect, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpectator = ref.watch(controlledPlayerProvider.select((player) => player == null));
    Color textColor = player.alive ? Colors.black : Colors.white;
    return GestureDetector(
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
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onSelect == null
              ? const Color.fromARGB(255, 245, 198, 128)
              : selected
                  ? Colors.orange[700]
                  : Colors.orange[400],
        ),
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
                    ...List.generate(math.max(player.maxLives - math.max(player.lives, 0), 0), (index) => Icon(Icons.favorite_border, color: textColor)),
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
