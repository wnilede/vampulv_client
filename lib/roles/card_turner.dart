import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/role_card_view.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class CardTurner extends Role {
  CardTurner()
      : super(
          type: RoleType.seer,
          reactions: [
            RoleReaction<NightBeginsEvent>(
              priority: 30,
              onApply: (event, game, player) => InputHandler(
                description: 'Välj spelare att använda kortvändaren på',
                resultApplyer: (input, game, string) {
                  final seenPlayer = game.playerFromId(int.parse(input.message));
                  final seenRole = seenPlayer.roles[game.randomGenerator.nextInt(seenPlayer.roles.length)];
                  return InputHandler.confirmChild(
                    description: 'See kort visat av kortvändare',
                    child: Center(
                      child: Column(
                        children: [
                          Text('En av rollerna som ${seenPlayer.configuration.name} har är'),
                          RoleCardView(seenRole.type),
                        ],
                      ),
                    ),
                  );
                },
                widget: const CardTurnerChoosingWidget(),
              ),
            )
          ],
        );
}

class CardTurnerChoosingWidget extends ConsumerWidget {
  const CardTurnerChoosingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayerMap(
      onDone: (List<Player> selected) {
        ref.read(messageSenderProvider).sendPlayerInput('${selected.single.configuration.id}');
      },
      description: 'Välj vem du vill se huruvida de är vampyr',
      numberSelected: 1,
    );
  }
}
