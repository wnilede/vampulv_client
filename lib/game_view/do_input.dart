import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_logic/game_provider.dart';
import '../network/connected_device_provider.dart';
import 'game_finished.dart';
import 'nothing_to_do_widget.dart';

class DoInput extends ConsumerWidget {
  final Widget drawer;

  const DoInput({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider)!;
    final gameIsFinished = ref.watch(cGameProvider.select((game) => game!.isFinished));
    if (gameIsFinished) {
      return GameFinished(drawer: drawer);
    }
    final inputHandler = controlledPlayer.currentInputHandler;
    return Scaffold(
      appBar: AppBar(title: inputHandler?.title == null ? const Text('Vampulv') : Text(inputHandler!.title!)),
      drawer: drawer,
      body: inputHandler?.widget ?? const NothingToDoWidget(),
    );
  }
}
