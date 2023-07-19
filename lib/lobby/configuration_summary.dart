import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/lobby/game_settings.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

class ConfigurationSummary extends ConsumerWidget {
  const ConfigurationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(gameConfigurationProvider);
    final gameHasBegun = ref.watch(currentSynchronizedDataProvider.select((sd) => sd.game.hasBegun));
    return ListView(
      shrinkWrap: true,
      children: [
        _ValueSummary(label: 'Antal liv från början', value: configuration.maxLives.toString()),
        _ValueSummary(label: 'Antal roller per spelare', value: configuration.rolesPerPlayer.toString()),
        if (!gameHasBegun)
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

class _ValueSummary extends StatelessWidget {
  final String label;
  final String value;

  const _ValueSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
