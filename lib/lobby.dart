import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/iterables.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_bodies/changedevicecontrolsbody.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/synchronized_data.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/user_maps/change_player_order_map.dart';

class Lobby extends ConsumerStatefulWidget {
  const Lobby({super.key});

  @override
  ConsumerState<Lobby> createState() => _LobbyState();
}

class _LobbyState extends ConsumerState<Lobby> {
  PlayerConfiguration? selectedPlayer;

  @override
  Widget build(BuildContext context) {
    GameConfiguration gameConfiguration = ref.watch(synchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration));
    int? deviceIdentifier = ref.watch(connectedDeviceIdentifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ChangePlayerOrderMap(
            selectedPlayerId: selectedPlayer?.id,
            onTap: (player) {
              setState(() {
                selectedPlayer = player;
              });
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: selectedPlayer == null || deviceIdentifier == null
                    ? null
                    : () {
                        ref.read(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                              type: NetworkMessageType.changeDeviceControls,
                              body: ChangeDeviceControlsBody(
                                deviceToChangeId: deviceIdentifier,
                                playerToControlId: selectedPlayer!.id,
                              ),
                            ));
                      },
                child: const Text('Styr spelare'),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  ref.read(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                        type: NetworkMessageType.setGameConfiguration,
                        body: gameConfiguration.copyWith(players: [
                          ...gameConfiguration.players,
                          PlayerConfiguration(
                            id: count().where((i) => gameConfiguration.players.every((player) => player.id != i)).first as int,
                            name: '${Random().nextInt(900) + 100}',
                          )
                        ]),
                      ));
                },
                child: const Text('Lägg till spelare'),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  final SynchronizedData synchronizedData = ref.read(synchronizedDataProvider);
                  ref.read(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                        type: NetworkMessageType.setSynchronizedData,
                        body: synchronizedData.copyWith(gameHasBegun: true),
                      ));
                },
                child: const Text('Starta'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
