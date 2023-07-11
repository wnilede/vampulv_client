import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';

class SpectatorOverview extends ConsumerStatefulWidget {
  const SpectatorOverview({super.key});

  @override
  ConsumerState<SpectatorOverview> createState() => _SpectatorViewState();
}

class _SpectatorViewState extends ConsumerState<SpectatorOverview> {
  @override
  Widget build(BuildContext context) {
    final players = ref.watch(gameProvider.select((game) => game?.players ?? []));
    return ListView(
      children: players
          .map((player) => ListView(
                scrollDirection: Axis.horizontal,
                children: player.unhandledInputHandlers.map((inputHandler) => inputHandler.),
              ))
          .toList(),
    );
  }
}

class SpectatorAppBar extends StatefulWidget {
  const SpectatorAppBar({super.key});

  @override
  State<SpectatorAppBar> createState() => _SpectatorAppBarState();
}

class _SpectatorAppBarState extends State<SpectatorAppBar> {
  TabController tabController;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
