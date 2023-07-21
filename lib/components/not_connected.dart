import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/message_sender_provider.dart';

class NotConnected extends ConsumerWidget {
  const NotConnected({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inte ansluten'),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(cMessageSenderProvider);
              },
              child: const Text('Försök igen'),
            )
          ],
        ),
      ),
    );
  }
}
