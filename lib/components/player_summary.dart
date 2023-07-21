import 'package:flutter/material.dart';

import '../game_logic/player.dart';
import '../game_view/log_page.dart';
import 'role_card_view.dart';

class PlayerSummary extends StatelessWidget {
  final Player player;

  const PlayerSummary(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: player.roles //
                    .map((role) => RoleCardView(role))
                    .toList(),
              ),
            ),
          ),
          Text(
            'Namn:  ${player.name}\nLiv:  ${player.lives}/${player.maxLives}\nLever:  ${player.alive ? 'Ja' : 'Nej'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => LogPage(
                          player: player,
                          drawer: null,
                        )),
                  ),
                );
              },
              child: const Text('Historik'),
            ),
          ),
        ],
      ),
    );
  }
}
