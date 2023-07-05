import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';

class GameViewPlayer extends ConsumerWidget {
  const GameViewPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    return controlledPlayer?.unhandledInputHandlers.firstOrNull?.widget ?? const Center(child: Text('Väntar på andra spelare...'));
  }
}
