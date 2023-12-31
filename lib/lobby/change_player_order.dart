import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/circular_layout.dart';
import '../game_logic/player_configuration.dart';
import '../network/connected_device_provider.dart';
import '../network/message_sender.dart';
import '../network/message_sender_provider.dart';
import '../network/synchronized_data_provider.dart';
import 'edit_player.dart';

class ChangePlayerOrderMap extends ConsumerStatefulWidget {
  const ChangePlayerOrderMap({super.key});

  @override
  ConsumerState<ChangePlayerOrderMap> createState() => _ChangePlayerOrderMapState();
}

class _ChangePlayerOrderMapState extends ConsumerState<ChangePlayerOrderMap> {
  int? selectedPlayerId;

  @override
  Widget build(BuildContext context) {
    final gameConfiguration = ref.watch(cSynchronizedDataProvider.select((synchronizedData) => synchronizedData.game.configuration));
    if (gameConfiguration.players.every((player) => player.id != selectedPlayerId)) {
      // Happens when someone removes the player that we have selected.
      selectedPlayerId = null;
    }
    int? deviceIdentifier = ref.watch(connectedDeviceIdentifierProvider);
    return Column(
      children: [
        if (gameConfiguration.players.isEmpty)
          const Expanded(
              child: Center(
                  child: Text(
            'There are no players yet',
            textAlign: TextAlign.center,
          ))),
        if (gameConfiguration.players.isNotEmpty)
          () {
            final playerWidgets = gameConfiguration.players.indexed
                .map((indexPlayerPair) => GestureDetector(
                      key: ValueKey(indexPlayerPair.$2.id),
                      onTap: () {
                        setState(() {
                          selectedPlayerId = gameConfiguration.players[indexPlayerPair.$1].id;
                        });
                      },
                      child: LongPressDraggable(
                        feedback: Text(indexPlayerPair.$2.name, style: Theme.of(context).textTheme.titleLarge),
                        data: indexPlayerPair.$1,
                        child: FittedBox(
                            child: Text(indexPlayerPair.$2.name,
                                style: TextStyle(color: indexPlayerPair.$2.id == selectedPlayerId ? Colors.blue : Colors.black))),
                      ),
                    ))
                .toList();
            final betweenPlayers = List.generate(
              gameConfiguration.players.length,
              (indexTo) => DragTarget(
                onAccept: (int indexFrom) {
                  // Some of these would break the following algorithm. Unneccessary to send message if nothing changes anyway.
                  if (indexFrom == indexTo || indexFrom == indexTo + 1 || indexFrom == 0 && indexTo == gameConfiguration.players.length - 1) {
                    return;
                  }
                  final List<PlayerConfiguration> newPlayerOrder = [
                    ...gameConfiguration.players,
                  ];
                  newPlayerOrder.insert(indexTo + (indexFrom > indexTo ? 1 : 0), newPlayerOrder.removeAt(indexFrom));
                  ref.read(cMessageSenderProvider).sendGameConfiguration(gameConfiguration.copyWith(players: newPlayerOrder));
                },
                builder: (context, candidateData, rejectedData) {
                  return const SizedBox();
                },
              ),
            );
            final controlledPlayerId =
                ref.watch(connectedDeviceProvider)?.controlledPlayerId ?? gameConfiguration.players.map((player) => player.id).min();
            final rotationCurrent = -gameConfiguration.players.indexWhere((player) => player.id == controlledPlayerId) *
                2 *
                math.pi /
                gameConfiguration.players.length;
            return Expanded(
              child: Stack(
                children: [
                  CircularLayout(rotationOffset: rotationCurrent, children: playerWidgets),
                  CircularLayout(rotationOffset: rotationCurrent + math.pi / gameConfiguration.players.length, children: betweenPlayers),
                ],
              ),
            );
          }(),
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditPlayer(null)),
                  );
                },
                child: const Text('Lägg till spelare', textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: selectedPlayerId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditPlayer(selectedPlayerId)),
                        );
                      },
                child: const Text('Redigera spelare', textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: selectedPlayerId == null
                    ? null
                    : () {
                        MessageSender messageSender = ref.read(cMessageSenderProvider);
                        // If someone controls the player that is to be removed, we must remove that link first.
                        for (final device in ref.read(cSynchronizedDataProvider).connectedDevices) {
                          if (device.controlledPlayerId == selectedPlayerId) {
                            messageSender.sendDeviceControls(device.identifier, null);
                          }
                        }
                        // Send the actual change.
                        messageSender.sendGameConfiguration(gameConfiguration.copyWith(
                            players: gameConfiguration.players.where((player) => player.id != selectedPlayerId).toList()));
                      },
                child: const Text('Ta bort spelare', textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: selectedPlayerId == null ||
                        deviceIdentifier == null ||
                        selectedPlayerId == ref.read(connectedDeviceProvider)?.controlledPlayerId
                    ? null
                    : () {
                        ref.read(cMessageSenderProvider).sendDeviceControls(deviceIdentifier, selectedPlayerId);
                      },
                child: const Text('Styr spelare', textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: selectedPlayerId == null || ref.read(connectedDeviceProvider)?.controlledPlayerId == null
                    ? null
                    : () {
                        ref.read(cMessageSenderProvider).sendDeviceControls(deviceIdentifier!, null);
                      },
                child: const Text('Sluta styr spelare', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
