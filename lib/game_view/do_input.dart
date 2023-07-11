import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_bodies/propose_lynching_body.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/user_maps/user_map.dart';

class DoInput extends ConsumerWidget {
  final Widget drawer;

  const DoInput({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    final isNight = ref.watch(gameProvider.select((game) => game!.isNight));
    return Scaffold(
      appBar: AppBar(title: controlledPlayer?.currentInputHandler?.description == null ? null : Text(controlledPlayer!.currentInputHandler!.description)),
      drawer: drawer,
      body: controlledPlayer?.currentInputHandler?.widget ??
          (isNight //
              ? const Center(child: Text('Väntar på andra spelare...', textAlign: TextAlign.center))
              : PlayerMap(
                  description: 'Välj någon att lyncha',
                  onDone: (selected) {
                    ref.watch(messageSenderProvider).sendChange(NetworkMessage.fromObject(
                          type: NetworkMessageType.proposeLynching,
                          body: ProposeLynchingBody(
                            proposerId: controlledPlayer!.configuration.id,
                            proposedId: selected.single.configuration.id,
                          ),
                        ));
                  },
                  numberSelected: 1,
                )),
    );
  }
}
