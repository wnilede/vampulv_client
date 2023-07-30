import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_settings/change_server.dart';
import '../network/message_sender_provider.dart';

class NotConnected extends ConsumerWidget {
  const NotConnected({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageSender = ref.watch(cMessageSenderProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: messageSender.isConnecting
              ? const [
                  Text('Ansluter till server...'),
                  CircularProgressIndicator(),
                ]
              : [
                  Text(
                    messageSender.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangeServer()),
                        );
                      },
                      child: const Text('Öppna serverinställningar', textAlign: TextAlign.center),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      onPressed: () {
                        ref.invalidate(cMessageSenderProvider);
                      },
                      child: const Text('Försök igen', textAlign: TextAlign.center),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
