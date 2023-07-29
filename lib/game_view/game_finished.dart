import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final otherPlayers = ref.watch(cGameProvider.select((game) => game!.players));
    return Scaffold(
      appBar: AppBar(title: const Text('Resultat')),
      drawer: drawer,
      body: Center(
        child: SingleChildScrollView(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: controlledPlayer.isWinner ? 'Du vann!' : 'Du förlorade!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextSpan(
                text: otherPlayers
                    .where((player) => player.id != controlledPlayer.id)
                    .map((player) =>
                        '\n${player.name} ${player.isWinner ? 'vann' : 'förlorade'} med ${player.roles.isEmpty ? 'inga roller' : player.roles.map((role) => role.type.displayName).listedNicelyAnd}')
                    .join(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
