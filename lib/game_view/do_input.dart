import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';

class DoInput extends ConsumerWidget {
  final Widget drawer;

  const DoInput({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlledPlayer = ref.watch(controlledPlayerProvider);
    return Scaffold(
      appBar: AppBar(title: controlledPlayer?.currentInputHandler?.description == null ? null : Text(controlledPlayer!.currentInputHandler!.description)),
      drawer: drawer,
      body: controlledPlayer?.currentInputHandler?.widget ?? const Center(child: Text('Väntar på andra spelare...', textAlign: TextAlign.center)),
    );
  }
}
