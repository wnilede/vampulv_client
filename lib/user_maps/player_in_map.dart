import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vampulv/player.dart';

class PlayerInMap extends StatelessWidget {
  final Player player;
  final bool selected;
  final void Function()? onSelect;

  const PlayerInMap(this.player, {this.selected = false, this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    Color textColor = player.alive ? Colors.black : Colors.white;
    return GestureDetector(
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
                    player.configuration.name,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(player.lives, (index) => Icon(Icons.favorite, color: textColor)),
                    ...List.generate(player.maxLives - player.lives, (index) => Icon(Icons.favorite_border, color: textColor)),
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
