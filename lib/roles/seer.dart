import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Seer extends Role {
  Seer()
      : super(
          type: RoleType.seer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 30,
              onApply: (event, game, player) => InputHandler(
                description: 'Välj spelare att använda spådamen på',
                resultApplyer: (input, game, string) {
                  final seenPlayer = game.playerFromId(int.parse(input.message));
                  final seenPlayerIsVampulv = seenPlayer.roles.any((role) => role.type == RoleType.vampulv || role.type == RoleType.lycan);
                  return [
                    InputHandler.confirmMessage('${seenPlayer.configuration.name} är ${seenPlayerIsVampulv ? '' : 'inte '}en vampulv!'),
                    'Du använde din spådam för att se att ${seenPlayer.configuration.name} ${seenPlayerIsVampulv ? '' : 'inte '}var en vampulv.',
                  ];
                },
                widget: const SeerChoosingWidget(),
              ),
            )
          ],
        );
}

class SeerChoosingWidget extends ConsumerWidget {
  const SeerChoosingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayerMap(
      onDone: (List<Player> selected) {
        ref.read(messageSenderProvider).sendPlayerInput('${selected.single.configuration.id}');
      },
      description: 'Välj vem du vill se huruvida de är vampulv',
      numberSelected: 1,
    );
  }
}
