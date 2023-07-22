import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/configuration_summary.dart';
import '../components/list_item.dart';
import '../components/player_summary.dart';
import '../components/role_card_view.dart';
import '../network/connected_device_provider.dart';
import '../network/synchronized_data_provider.dart';

class Information extends ConsumerWidget {
  final Widget drawer;

  const Information({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(controlledPlayerProvider);
    final forcedRoles = ref.watch(cSynchronizedDataProvider.select((sd) => sd.game.configuration.forcedRoles));
    final ordinaryRoles = ref.watch(cSynchronizedDataProvider.select((sd) => sd.game.configuration.ordinaryRoles));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information'),
      ),
      drawer: drawer,
      body: ListView(
        children: [
          ListItem(
            child: Column(
              children: [
                Text(
                  'Om dig själv',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                player == null ? const Text('Du är inte med i spelet så du får se allt.') : PlayerSummary(player),
              ],
            ),
          ),
          ListItem(
            child: Column(
              children: [
                Text(
                  'Om spelet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const ConfigurationSummary(),
                if (forcedRoles.isNotEmpty)
                  Text(
                    'Roller som är med',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                if (forcedRoles.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: forcedRoles.map((role) => RoleTypeCardView(role)).toList(),
                      ),
                    ),
                  ),
                if (ordinaryRoles.isNotEmpty)
                  Text(
                    'Roller som kanske är med',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                if (ordinaryRoles.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: ordinaryRoles.map((role) => RoleTypeCardView(role)).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
