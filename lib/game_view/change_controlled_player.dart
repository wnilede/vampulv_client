import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/user_maps/user_map.dart';

class ChangeControlledPlayer extends ConsumerWidget {
  final Widget drawer;

  const ChangeControlledPlayer({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Ändra spelare')),
        drawer: drawer,
        body: PlayerMap(
          onDone: (selected) {
            int? deviceId = ref.read(connectedDeviceIdentifierProvider);
            if (deviceId == null) return;
            ref.read(currentMessageSenderProvider).sendDeviceControls(deviceId, selected.singleOrNull?.configuration.id);
          },
          numberSelected: 1,
          canChooseFewer: true,
          deadPlayersSelectable: true,
        ),
      );
}
