import 'package:flutter/material.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/role_card_view.dart';

class PlayerSummary extends StatelessWidget {
  final Player player;

  const PlayerSummary(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 200,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: player.roles //
                  .map((role) => RoleCardView(role.type))
                  .toList(),
            ),
          ),
          Text(
            'Namn:   ${player.name}\nLiv:   ${player.lives}/${player.maxLives}\nLever:   ${player.alive ? 'Ja' : 'Nej'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
