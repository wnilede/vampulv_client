import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/user_maps/circular_layout.dart';

class ChangePlayerOrderMap extends ConsumerWidget {
  final int? selectedPlayerId;
  final void Function(PlayerConfiguration player)? onTap;

  const ChangePlayerOrderMap({this.selectedPlayerId, this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameConfiguration = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration));
    if (gameConfiguration.players.isEmpty) {
      return const Center(child: Text('There are no players yet'));
    }
    final playerWidgets = gameConfiguration.players
        .asMap()
        .entries
        .map((indexPlayerPair) => GestureDetector(
              key: ValueKey(indexPlayerPair.value.id),
              onTap: () => onTap?.call(gameConfiguration.players[indexPlayerPair.key]),
              child: LongPressDraggable(
                feedback: Text(indexPlayerPair.value.name),
                data: indexPlayerPair.key,
                child: FittedBox(child: Text(indexPlayerPair.value.name, style: TextStyle(color: indexPlayerPair.value.id == selectedPlayerId ? Colors.blue : Colors.black))),
              ),
            ))
        .toList();
    final betweenPlayers = gameConfiguration.players
        .asMap()
        .entries
        .map((final indexPlayerPair) => DragTarget(
              onAccept: (int indexFrom) {
                final int indexTo = indexPlayerPair.key;
                // Some of these would break the following algorithm. Unneccessary to send message if nothing changes anyway.
                if (indexFrom == indexTo || indexFrom == indexTo + 1 || indexFrom == 0 && indexTo == gameConfiguration.players.length - 1) return;
                final List<PlayerConfiguration> newPlayerOrder = [
                  ...gameConfiguration.players,
                ];
                newPlayerOrder.insert(indexTo + (indexFrom > indexTo ? 1 : 0), newPlayerOrder.removeAt(indexFrom));
                ref.read(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                      type: NetworkMessageType.setGameConfiguration,
                      body: gameConfiguration.copyWith(players: newPlayerOrder),
                    ));
              },
              builder: (BuildContext context, List<int?> candidateData, List rejectedData) {
                return const SizedBox();
              },
            ))
        .toList();
    final controlledPlayerId = ref.watch(connectedDeviceProvider)?.controlledPlayerId ?? gameConfiguration.players.map((player) => player.id).min();
    final rotationCurrent = -gameConfiguration.players.indexWhere((player) => player.id == controlledPlayerId) * 2 * math.pi / gameConfiguration.players.length;
    return Stack(
      children: [
        CircularLayout(rotationOffset: rotationCurrent, children: playerWidgets),
        CircularLayout(rotationOffset: rotationCurrent + math.pi / gameConfiguration.players.length, children: betweenPlayers),
      ],
    );
  }
}
