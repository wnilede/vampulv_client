import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game_logic/game_provider.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import 'context_aware_text.dart';

class RoleTypeDescription extends StatelessWidget {
  final RoleType role;

  const RoleTypeDescription(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Rolldetaljer')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text(
            role.displayName,
            style: theme.textTheme.headlineMedium,
          ),
          ContextAwareText(
            role.summary,
            style: theme.textTheme.titleMedium,
          ),
          ContextAwareText(
            role.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class RoleDescription extends ConsumerWidget {
  final Role role;

  const RoleDescription(this.role, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(cGameProvider);
    if (game == null) {
      return RoleTypeDescription(role.type);
    }
    final theme = Theme.of(context);
    final owner = game.players.firstWhereOrDefault((player) => player.roles.contains(role));
    if (owner == null) {
      return RoleTypeDescription(role.type);
    }
    final displayableProperties = role.getDisplayableProperties(game, owner);
    displayableProperties['Ägare'] = owner.name;
    return Scaffold(
      appBar: AppBar(title: const Text('Rolldetaljer')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text(
            role.getDisplayName(game, owner),
            style: theme.textTheme.headlineMedium,
          ),
          ContextAwareText(
            role.getSummary(game, owner),
            style: theme.textTheme.titleMedium,
          ),
          ContextAwareText(
            role.getDescription(game, owner),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          ...displayableProperties.entries.map((property) => Text(
                '${property.key}: ${property.value}',
                style: Theme.of(context).textTheme.bodyLarge,
              )),
        ],
      ),
    );
  }
}
