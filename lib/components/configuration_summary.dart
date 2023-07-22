import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/synchronized_data_provider.dart';

class ConfigurationSummary extends ConsumerWidget {
  const ConfigurationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(gameConfigurationProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueSummary(label: 'Antal liv från början', value: configuration.maxLives.toString()),
        _ValueSummary(label: 'Antal roller per spelare', value: configuration.rolesPerPlayer.toString()),
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
