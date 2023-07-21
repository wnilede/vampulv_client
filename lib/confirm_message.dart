import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/message_sender_provider.dart';

class ConfirmMessage extends ConsumerWidget {
  final Widget child;
  final String inputIdentifier;

  const ConfirmMessage({required this.inputIdentifier, required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: child),
        MaterialButton(
          onPressed: () {
            ref.read(cMessageSenderProvider).sendPlayerInput('', inputIdentifier);
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}
