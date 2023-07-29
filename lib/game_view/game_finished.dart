import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/context_aware_text.dart';
import '../game_logic/game_provider.dart';
import '../network/connected_device_provider.dart';
import '../utility/list_strings_nicely.dart';

class GameFinished extends ConsumerWidget {
  const GameFinished({
    super.key,
    required this.drawer,
  });

  final Widget drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider)!;
    final players = ref.watch(cGameProvider.select((game) => game!.players));
    return Scaffold(
      appBar: AppBar(title: const Text('Resultat')),
      drawer: drawer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                controlledPlayer.isWinner ? 'Du vann!' : 'Du förlorade!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              ...players.where((player) => player.id != controlledPlayer.id).map(
                    (player) => ContextAwareText(
                      '${player.name} ${player.isWinner ? 'vann' : 'förlorade'} med ${player.roles.isEmpty ? 'inga roller' : player.roles.map((role) => '&${role.type.name}').listedNicelyAnd}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
              // ContextAwareText(
              //   players
              //       .where((player) => player.id != controlledPlayer.id)
              //       .map((player) =>
              //           '${player.name} ${player.isWinner ? 'vann' : 'förlorade'} med ${player.roles.isEmpty ? 'inga roller' : player.roles.map((role) => '&${role.type.name}').listedNicelyAnd}')
              //       .join('\n'),
              //   style: Theme.of(context).textTheme.bodyLarge,
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
