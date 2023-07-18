import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/lobby/choose_roles.dart';
import 'package:vampulv/lobby/configuration_summary.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/synchronized_data.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/player_configuration.dart';
import 'package:vampulv/lobby/change_player_order.dart';

class Lobby extends ConsumerStatefulWidget {
  const Lobby({super.key});

  @override
  ConsumerState<Lobby> createState() => _LobbyState();
}

class _LobbyState extends ConsumerState<Lobby> {
  PlayerConfiguration? selectedPlayer;

  @override
  Widget build(BuildContext context) {
    final gameConfiguration = ref.watch(currentSynchronizedDataProvider.select((sd) => sd.gameConfiguration));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inställningar nytt spel'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.groups)),
              Tab(icon: Icon(Icons.view_list)),
              Tab(icon: Icon(Icons.warning)),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: TabBarView(
                children: [
                  ChangePlayerOrderMap(),
                  ChooseRoles(),
                  ConfigurationSummary(),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: gameConfiguration.players.length * gameConfiguration.rolesPerPlayer > gameConfiguration.roles.length || gameConfiguration.players.length < 3
                        ? null
                        : () {
                            final SynchronizedData synchronizedData = ref.read(currentSynchronizedDataProvider);
                            ref.read(currentMessageSenderProvider).sendChange(NetworkMessage.fromObject(
                                  type: NetworkMessageType.setSynchronizedData,
                                  body: synchronizedData.copyWith(gameHasBegun: true),
                                ));
                          },
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
