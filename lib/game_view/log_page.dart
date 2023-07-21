import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/list_item.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/player.dart';

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
                            Text(logEntry.value),
                          ],
                        )
                      : Text(logEntry.value),
                ))
            .reverse()
            .toList(),
      ),
    );
  }
}
