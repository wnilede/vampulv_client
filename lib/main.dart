import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'components/not_connected.dart';
import 'game_logic/game_provider.dart';
import 'game_view/game_view.dart';
import 'lobby/create_game_view.dart';
import 'network/message_sender_provider.dart';
import 'network/synchronized_data_provider.dart';

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
    return MaterialApp(
      theme: ref.watch(cGameProvider.select((game) => game?.isNight ?? false)) ? ThemeData.dark() : ThemeData.light(),
      home: ref.watch(cMessageSenderProvider.select((messageSender) => messageSender.isConnected))
          ? ref.watch(cSynchronizedDataProvider).game.hasBegun
              ? const GameView()
              : const CreateGameView()
          : const NotConnected(),
    );
  }
}
