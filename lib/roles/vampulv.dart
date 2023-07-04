import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/synchronized_data/network_message.dart';
import 'package:vampulv/synchronized_data/network_message_type.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Vampulv extends Role {
  Vampulv()
      : super(
          reactions: [
            RoleReaction(
              priority: 100,
              applyer: (game, owner) => InputHandler(
                resultApplyer: (world, _) => world,
                widget: const VampulvChoosingWidget(),
              ),
            ),
          ],
        );
}

class VampulvRule extends Rule {
  VampulvRule()
      : super(reactions: [
          RuleReaction(
            priority: 50,
            applyer: (Game game) => Event(type: EventType.vampulvsAttacks),
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
