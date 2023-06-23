import 'dart:math' as math;

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
    final gameConfigurations = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration));
    final playerWidgets = gameConfigurations.players
        .asMap()
        .entries
        .map((indexPlayerPair) => Draggable(
              feedback: Text(indexPlayerPair.value.name),
              data: indexPlayerPair.key,
              child: Center(child: Text(indexPlayerPair.value.name)),
            ))
        .toList();
    final betweenPlayers = gameConfigurations.players
        .asMap()
        .entries
        .map((final indexPlayerPair) => DragTarget(
              onAccept: (int data) {
                // Some of these would break the following algorithm. Unneccessary to send message if nothing changes anyway.
                if (data == indexPlayerPair.key || data == indexPlayerPair.key - 1 || data == gameConfigurations.players.length - 1 && indexPlayerPair.key == 0) return;
                final List<PlayerConfiguration> newPlayerOrder = [];
                for (int i = 1; i < gameConfigurations.players.length; i++) {
                  newPlayerOrder.add(gameConfigurations.players[(i + data) % gameConfigurations.players.length]);
                  if (i == indexPlayerPair.key) {
                    newPlayerOrder.add(gameConfigurations.players[data]);
                  }
                }
                ref.read(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                      type: NetworkMessageType.setGameConfiguration,
                      body: gameConfigurations.copyWith(players: newPlayerOrder),
                    ));
              },
              builder: (BuildContext context, List<PlayerConfiguration?> candidateData, List rejectedData) {
                return const Placeholder();
              },
            ))
        .toList();
    return gameConfigurations.players.isEmpty
        ? const Text('There are no players yet')
        : Stack(
            children: [
              CircularLayout(children: playerWidgets),
              CircularLayout(rotationOffset: math.pi / gameConfigurations.players.length, children: betweenPlayers),
            ],
          );
  }
}
