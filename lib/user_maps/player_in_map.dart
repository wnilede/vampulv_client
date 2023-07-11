import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vampulv/player.dart';

class PlayerInMap extends StatelessWidget {
  final Player player;
  final bool selected;
  final bool selectable;

  const PlayerInMap(this.player, {this.selected = false, this.selectable = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selectable
            ? selected
                ? Colors.orange[700]
                : const Color.fromARGB(255, 245, 198, 128)
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
                  player.configuration.name,
                  style: TextStyle(color: player.alive ? Colors.black : Colors.white),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(player.lives, (index) => const Icon(Icons.favorite)),
                  ...List.generate(player.maxLives - player.lives, (index) => const Icon(Icons.favorite_border)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
