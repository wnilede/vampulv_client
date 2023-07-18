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
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.brown,
          type: MaterialType.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(width: 3, color: Colors.grey),
          ),
          child: InkWell(
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
            child: SizedBox(
              width: 170,
              height: 230,
              child: Padding(
                padding: const EdgeInsets.all(6),
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
          ),
        ),
      ),
    );
  }
}
