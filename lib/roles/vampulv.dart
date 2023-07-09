import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Vampulv extends Role {
  Vampulv()
      : super(
          type: RoleType.vampulv,
          reactions: [
            RoleReaction(
              priority: 100,
              applyer: (event, game, owner) => event.type == EventType.nightBegins
                  ? InputHandler(
                      resultApplyer: (input, game, player) => null,
                      widget: const VampulvChoosingWidget(),
                    )
                  : null,
            ),
          ],
        );
}

class VampulvRule extends Rule {
  VampulvRule()
      : super(reactions: [
          RuleReaction(
            priority: 50,
            applyer: (event, game) => event.type == EventType.nightBegins ? Event(type: EventType.vampulvsAttacks) : null,
          )
        ]);
}

class VampulvChoosingWidget extends ConsumerWidget {
  const VampulvChoosingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserMap(
      onDone: (List<Player> selected) {
        ref.read(messageSenderProvider).sendChange(NetworkMessage(
              type: NetworkMessageType.inputToGame,
              message: '${selected.single.configuration.id}',
            ));
      },
      description: 'Välj vem vampyrerna ska attakera',
      numberSelected: 1,
    );
  }
}
