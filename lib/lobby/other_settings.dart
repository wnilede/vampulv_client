import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/configuration_summary.dart';
import '../lobby/game_settings.dart';
import '../network/synchronized_data_provider.dart';

class OtherSettings extends ConsumerWidget {
  const OtherSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(gameConfigurationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              const ConfigurationSummary(),
              if (configuration.problems.isNotEmpty)
                Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.all(4),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Problem',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                      TextSpan(
                        text: configuration.problems.map((problem) => '\n - $problem').join(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: (() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameSettings()),
              );
            }),
            child: const Text('Ändra'),
          ),
        )
      ],
    );
  }
}
