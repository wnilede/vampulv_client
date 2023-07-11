import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/message_sender_provider.dart';

class BinaryChoice extends ConsumerWidget {
  final String title;
  final String falseChoice;
  final String trueChoice;

  const BinaryChoice({required this.title, this.falseChoice = 'Nej', this.trueChoice = 'Yes', super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Flex(
              direction: constraints.maxHeight > constraints.maxWidth ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: () => ref.read(messageSenderProvider).sendPlayerInput('false'),
                    child: Text(falseChoice, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: () => ref.read(messageSenderProvider).sendPlayerInput('true'),
                    child: Text(trueChoice, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
