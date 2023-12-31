import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/player_map.dart';
import '../game_logic/game_provider.dart';
import '../network/connected_device_provider.dart';
import '../network/message_bodies/propose_lynching_body.dart';
import '../network/message_bodies/set_done_lynching_body.dart';
import '../network/message_sender_provider.dart';
import '../network/network_message.dart';
import '../network/network_message_type.dart';

class NothingToDoWidget extends ConsumerWidget {
  final bool canLyncha;

  const NothingToDoWidget({this.canLyncha = true, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider)!;
    final isNight = ref.watch(cGameProvider.select((game) => game!.isNight));
    return (isNight || !controlledPlayer.alive || !canLyncha
        ? const Center(child: Text('Väntar på andra spelare...', textAlign: TextAlign.center))
        : controlledPlayer.lynchingDone
            ? MaterialButton(
                onPressed: () {
                  ref.read(cMessageSenderProvider).sendChange(NetworkMessage.fromObject(
                        type: NetworkMessageType.doneLynching,
                        body: SetDoneLynchingBody(
                          playerId: controlledPlayer.id,
                          value: false,
                        ),
                      ));
                },
                child: const Center(child: Text('Föreslå lynchning', textAlign: TextAlign.center)),
              )
            : PlayerMap(
                description: 'Välj någon att lyncha',
                onDone: (selected) {
                  ref.read(cMessageSenderProvider).sendChange(NetworkMessage.fromObject(
                        type: NetworkMessageType.proposeLynching,
                        body: ProposeLynchingBody(
                          proposerId: controlledPlayer.id,
                          proposedId: selected.single.id,
                        ),
                      ));
                },
                onCancel: () {
                  ref.read(cMessageSenderProvider).sendChange(NetworkMessage.fromObject(
                        type: NetworkMessageType.doneLynching,
                        body: SetDoneLynchingBody(
                          playerId: controlledPlayer.id,
                          value: true,
                        ),
                      ));
                },
                numberSelected: 1,
                selectablePlayerFilter: controlledPlayer.previouslyProposed,
                reasonForbidden: 'Du kan bara föreslå varje spelare för lynching en gång per dag.',
              ));
  }
}
