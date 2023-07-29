import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/context_aware_text.dart';
import '../components/list_item.dart';
import '../game_logic/game_provider.dart';
import '../game_logic/player.dart';
import '../network/connected_device_provider.dart';

class LogPage extends ConsumerWidget {
  final Widget? drawer;
  final Player? player;

  const LogPage({this.player, required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = player ?? ref.watch(controlledPlayerProvider);
    final game = ref.watch(cGameProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historik')),
      drawer: drawer,
      body: ListView(
        reverse: true,
        children: game!.log
            .where((logEntry) =>
                logEntry.playerVisibleTo == null || //
                controlledPlayer == null ||
                logEntry.playerVisibleTo == controlledPlayer.id)
            .map((logEntry) => ListItem(
                  child: controlledPlayer == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              logEntry.playerVisibleTo == null
                                  ? 'Synligt för alla'
                                  : 'Från ${game.playerFromId(logEntry.playerVisibleTo!).namePossissive} historik',
                              style: Theme.of(context).textTheme.labelLarge, //.copyWith(color: Theme.of(context).colorScheme.),
                            ),
                            ContextAwareText(logEntry.value),
                          ],
                        )
                      : ContextAwareText(logEntry.value),
                ))
            .reverse()
            .toList(),
      ),
    );
  }
}
