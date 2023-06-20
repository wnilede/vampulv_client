import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/synchronized_data/synchronized_data_provider.dart';

import 'lobby.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: ref.watch(synchronizedDataProvider.select((g) => g.game.started)) ? const Placeholder() : const Lobby(),
      ),
    );
  }
}
