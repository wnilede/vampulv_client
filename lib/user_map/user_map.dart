import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/synchronized_data/synchronized_data_provider.dart';

class UserMap extends ConsumerWidget {
  final Widget Function(Player player)? playerAppearance;
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  const UserMap({this.playerAppearance, this.betweenPlayers, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      double radius = math.min(constraints.maxHeight, constraints.maxWidth) * 0.8;
      List<Player> players = ref.watch(synchronizedDataProvider.select((s) => s.game.users));
      return Column(
        children: [
          const Text('Lobby'),
          Text(players.map((e) => e.toString()).join()),
          Text(ref.watch(messageSenderProvider).toString()),
          Stack(
            children: players
                .map((player) => Positioned(
                      top: constraints.maxHeight / 2 + radius * math.sin(math.pi * player.position / players.length),
                      left: constraints.maxWidth / 2 + radius * math.cos(math.pi * player.position / players.length),
                      child: playerAppearance == null ? Text(player.name) : playerAppearance!(player),
                    ))
                .toList(),
          ),
        ],
      );
    });
  }
}
