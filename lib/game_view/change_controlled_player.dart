import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/user_maps/circular_layout.dart';

class ChangeControlledPlayer extends ConsumerWidget {
  const ChangeControlledPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CircularLayout(
      children: ref
          .watch(gameConfigurationProvider)
          .players
          .map((player) => GestureDetector(
                key: ValueKey(player.id),
                onTap: () {
                  int? deviceId = ref.read(connectedDeviceIdentifierProvider);
                  if (deviceId == null) return;
                  ref.read(messageSenderProvider).sendDeviceControls(deviceId, player.id);
                },
                child: FittedBox(child: Text(player.name)),
              ))
          .toList());
}
