import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/context_aware_text.dart';
import '../components/list_item.dart';
import '../game_logic/game_provider.dart';

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
        .watch(cGameProvider.select((game) => game?.players ?? []))
        .orderByDescending((player) => 2 * player.unhandledInputHandlers.length + (player.lynchingDone ? 0 : 1));
    final bool isNight = ref.watch(cGameProvider.select((game) => game!.isNight));
    return DefaultTabController(
      length: playersOrdered.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Att göra-listor'),
          bottom: TabBar(
              isScrollable: true,
              tabs: playersOrdered //
                  .map((player) => Text(player.name))
                  .toList()),
        ),
        drawer: widget.drawer,
        body: TabBarView(
            children: playersOrdered
                .map((player) => ListView(
                    children: player.unhandledInputHandlers
                        .map<Widget>((inputHandler) => ListItem(child: ContextAwareText(inputHandler.description)))
                        .defaultIfEmpty(Text(
                          player.lynchingDone || isNight ? 'Inget kvar att göra...' : 'Väljer spelare att förseslå för lynchning',
                          textAlign: TextAlign.center,
                        ))
                        .toList()))
                .toList()),
      ),
    );
  }
}
