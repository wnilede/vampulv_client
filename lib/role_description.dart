import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';

class RoleTypeDescription extends StatelessWidget {
  final RoleType role;

  const RoleTypeDescription(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Text(
          role.displayName,
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          role.description,
          style: theme.textTheme.titleMedium,
        ),
        Text(
          role.detailedDescription,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class RoleDescription extends ConsumerWidget {
  final Role role;

  const RoleDescription(this.role, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(currentGameProvider);
    if (game == null) {
      return RoleTypeDescription(role.type);
    }
    final owner = game.players.firstWhereOrDefault((player) => player.roles.contains(role));
    if (owner == null) {
      return RoleTypeDescription(role.type);
    }
    final displayableProperties = role.getDisplayableProperties(game, owner);
    if (displayableProperties.isEmpty) {
      return RoleTypeDescription(role.type);
    }
    return Column(
      children: [
        RoleTypeDescription(role.type),
        const SizedBox(height: 8),
        ...displayableProperties.entries.map((property) => Text(
              '${property.key}: ${property.value}',
              style: Theme.of(context).textTheme.bodyMedium,
            )),
      ],
    );
  }
}
