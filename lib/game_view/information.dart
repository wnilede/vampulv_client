import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/list_item.dart';
import 'package:vampulv/lobby/configuration_summary.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/player_summary.dart';
import 'package:vampulv/role_card_view.dart';

class Information extends ConsumerWidget {
  final Widget drawer;

  const Information({required this.drawer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(controlledPlayerProvider);
    final roles = ref.watch(currentSynchronizedDataProvider.select((sd) => sd.game.configuration.roles));
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
                Text(
                  'Roller som är med',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(
                  height: 100,
                  child: Center(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: roles.map((role) => RoleTypeCardView(role)).toList(),
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
