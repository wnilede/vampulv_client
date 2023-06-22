import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:vampulv/message_sender_provider.dart';
import 'package:vampulv/synchronized_data/synchronized_data_provider.dart';

import 'lobby.dart';

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
      home: Scaffold(
        body: Column(
          children: [
            if (!ref.watch(messageSenderProvider.select((messageSender) => messageSender.isConnected))) const Text('Not connected'),
            ref.watch(synchronizedDataProvider).gameHasBegun ? const Placeholder() : const Lobby(),
          ],
        ),
      ),
    );
  }
}
