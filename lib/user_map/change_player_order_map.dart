import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:vampulv/synchronized_data/network_message_type.dart';
import 'package:vampulv/synchronized_data/synchronized_data_provider.dart';
import 'package:vampulv/user_map/circular_layout.dart';

class ChangePlayerOrderMap extends ConsumerWidget {
  final Widget Function(Player player)? playerAppearance;
  final Widget Function(Player playerLeft, Player playerRight)? betweenPlayers;

  const ChangePlayerOrderMap({this.playerAppearance, this.betweenPlayers, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerConfigurations = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration.players));
    final playerWidgets = playerConfigurations
        .map((player) => Draggable(
              feedback: Text(player.name),
              data: player,
              child: Center(child: Text(player.name)),
            ))
        .toList();
    final betweenPlayers = playerConfigurations
        .asMap()
        .entries
        .map((final indexPlayerPair) => DragTarget(
              onAccept: (PlayerConfiguration data) {
                ref.read(messageSenderProvider).sendChange(NetworkMessage(
                      type: NetworkMessageType.movePlayer,
                      message: ("{oldPosition:${data.position},newPosition:${indexPlayerPair.key}}"),
                    ));
              },
              builder: (BuildContext context, List<PlayerConfiguration?> candidateData, List rejectedData) {
                return const Expanded(child: Placeholder());
              },
            ))
        .toList();
    List<Widget> children = [];
    for (var i = 0; i < playerWidgets.length; i++) {
      children.add(betweenPlayers[i]);
      children.add(playerWidgets[i]);
    }
    return CircularLayout(children: children);
  }
}
