import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/network/connected_device_provider.dart';

class LogPage extends ConsumerWidget {
  final Widget drawer;

  const LogPage({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    final logs = ref.watch(currentGameProvider.select((game) => game!.log));
    return Scaffold(
      appBar: AppBar(title: const Text('Historik')),
      drawer: drawer,
      body: ListView(
        children: logs
            .where((logEntry) =>
                logEntry.playerVisibleTo == null || //
                controlledPlayer == null ||
                logEntry.playerVisibleTo == controlledPlayer.id)
            .map((logEntry) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  child: Text(logEntry.value),
                ))
            .reverse()
            .toList(),
      ),
    );
  }
}
