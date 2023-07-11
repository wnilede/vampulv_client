import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_provider.dart';

class SpectatorOverview extends ConsumerStatefulWidget {
  final Widget drawer;

  const SpectatorOverview({required this.drawer, super.key});

  @override
  ConsumerState<SpectatorOverview> createState() => _SpectatorViewState();
}

class _SpectatorViewState extends ConsumerState<SpectatorOverview> {
  @override
  Widget build(BuildContext context) {
    final playersOrdered = ref
        .watch(gameProvider.select((game) => game?.players ?? [])) //
        .orderByDescending((player) => player.unhandledInputHandlers.length);
    return DefaultTabController(
      length: playersOrdered.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Att göra-listor'),
          bottom: TabBar(
              isScrollable: true,
              tabs: playersOrdered //
                  .map((player) => Text(player.configuration.name))
                  .toList()),
        ),
        drawer: widget.drawer,
        body: TabBarView(
            children: playersOrdered //
                .map((player) => ListView(
                    children: player.unhandledInputHandlers //
                        .map((inputHandler) => Text(inputHandler.description))
                        .defaultIfEmpty(const Text(
                          'Inget kvar att göra...',
                          textAlign: TextAlign.center,
                        ))
                        .toList()))
                .toList()),
      ),
    );
  }
}
