import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/game_view/game_view.dart';
import 'package:vampulv/lobby/lobby.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

void main() {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isNight = ref.watch(gameProvider.select((game) => game?.isNight ?? false));
    return MaterialApp(
      theme: isNight ? ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)) : ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)), //ThemeData.light(),
      home: ref.watch(messageSenderProvider.select((messageSender) => messageSender.isConnected))
          ? ref.watch(synchronizedDataProvider).gameHasBegun
              ? const GameView()
              : const Lobby()
          : const Scaffold(
              body: Center(child: Text('Not connected')),
            ),
    );
  }
}
