import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/game_view/nothing_to_do_widget.dart';
import 'package:vampulv/network/connected_device_provider.dart';

class DoInput extends ConsumerWidget {
  final Widget drawer;

  const DoInput({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider)!;
    if (ref.watch(currentGameProvider.select((game) => game!.isFinished))) {
      return Scaffold(
        appBar: AppBar(title: const Text('Spelet är slut')),
        drawer: drawer,
        body: Center(
          child: Text(
            controlledPlayer.isWinner ? 'Du vann!' : 'Du förlorade!',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      );
    }
    final inputHandler = controlledPlayer.currentInputHandler;
    return Scaffold(
      appBar: AppBar(title: inputHandler?.description == null ? const Text('Vampulv') : Text(inputHandler!.description)),
      drawer: drawer,
      body: inputHandler?.widget ?? const NothingToDoWidget(),
    );
  }
}
