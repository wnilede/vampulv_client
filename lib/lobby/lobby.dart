import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_logic/player_configuration.dart';
import '../network/message_sender_provider.dart';
import '../network/synchronized_data_provider.dart';
import 'change_player_order.dart';
import 'choose_roles.dart';
import 'other_settings.dart';

class Lobby extends ConsumerStatefulWidget {
  final Widget drawer;

  const Lobby({required this.drawer, super.key});

  @override
  ConsumerState<Lobby> createState() => _LobbyState();
}

class _LobbyState extends ConsumerState<Lobby> {
  PlayerConfiguration? selectedPlayer;

  @override
  Widget build(BuildContext context) {
    final gameConfiguration = ref.watch(cSynchronizedDataProvider.select((sd) => sd.game.configuration));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inställningar nytt spel'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.groups)),
              Tab(icon: Icon(Icons.view_list)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        drawer: widget.drawer,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: TabBarView(
                children: [
                  ChangePlayerOrderMap(),
                  ChooseRoles(),
                  OtherSettings(),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: gameConfiguration.problems.isEmpty
                        ? () {
                            ref.read(cMessageSenderProvider).sendSynchronizedData(
                                  ref.read(cSynchronizedDataProvider).copyWith.game(hasBegun: true),
                                );
                          }
                        : null,
                    child: const Text('Starta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum LobbySelection {
  configureGame,
  changeGame,
}
