import 'package:auto_size_text/auto_size_text.dart';
import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';

class RoleTypeCardView extends ConsumerWidget {
  final RoleType roleType;

  const RoleTypeCardView(this.roleType, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _RoleCardView(
        title: roleType.displayName,
        showedOnTap: RoleTypeDescription(roleType),
      );
}

class RoleCardView extends ConsumerWidget {
  final Role role;

  const RoleCardView(this.role, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(currentGameProvider);
    final owner = game?.players.firstWhereOrDefault((player) => player.roles.contains(role));
    return _RoleCardView(
      title: owner == null ? role.type.displayName : role.getDisplayName(game!, owner),
      showedOnTap: RoleDescription(role),
    );
  }
}

class _RoleCardView extends ConsumerWidget {
  final String title;
  final Widget showedOnTap;

  const _RoleCardView({required this.title, required this.showedOnTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              appBar: AppBar(title: const Text('Rolldetaljer')),
              body: showedOnTap,
            ),
          ),
        );
      },
      child: FittedBox(
        child: Container(
          width: 170,
          height: 230,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: FittedBox(child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSecondary)),
              ),
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
