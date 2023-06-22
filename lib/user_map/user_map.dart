import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/user_map/circular_layout.dart';

class UserMap extends ConsumerWidget {
  final Widget Function(Player player)? playerAppearance;
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  const UserMap({this.playerAppearance, this.betweenPlayers, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Player> players = ref.watch(gameProvider.select((game) => game!.players));
    return CircularLayout(
        children: players
            .map(
              (player) => playerAppearance == null ? Text(player.configuration.name) : playerAppearance!(player),
            )
            .toList());
  }
}
