import 'dart:convert';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/cheating_indicator.dart';
import 'package:vampulv/global_settings/saved_games_list.dart';
import 'package:vampulv/global_settings/shared_preferences_provider.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

class SaveLoad extends ConsumerStatefulWidget {
  const SaveLoad({super.key});

  @override
  ConsumerState<SaveLoad> createState() => _SaveLoadState();
}

class _SaveLoadState extends ConsumerState<SaveLoad> {
  final nameController = TextEditingController();
  String nameText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spara och öppna spel'),
      ),
      body: () {
        final gameHasBegun = ref.watch(currentSynchronizedDataProvider.select((sd) => sd.game.hasBegun));
        final prefs = ref.watch(currentSharedPreferencesProvider);

        if (prefs.isLoading) {
          return const Text('Laddar...');
        }
        if (!prefs.hasValue) {
          return const Text('Misslyckades med att läsa in lokalt sparad data.');
        }
        final serializedSavedGames = prefs.value!.getString('savedGames');
        final savedGames = serializedSavedGames == null ? SavedGamesList() : SavedGamesList.fromJson(json.decode(serializedSavedGames));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: TextField(controller: nameController),
            ),
            Expanded(
              child: ListView(
                children: savedGames.games.keys
                    .map(
                      (gameName) => InkWell(
                        onTap: () {
                          nameController.text = gameName;
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(gameName),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: nameText == ''
                        ? null
                        : () {
                            prefs.value!.setString(
                              'savedGames',
                              json.encode(
                                savedGames.copyWith(
                                  games: {
                                    ...savedGames.games,
                                    nameText: ref.read(currentSynchronizedDataProvider).game,
                                  },
                                ),
                              ),
                            );
                            ref.invalidate(currentSharedPreferencesProvider);
                          },
                    child: const Text('Spara'),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: savedGames.games.containsKey(nameText)
                        ? () {
                            final synchronizedData = ref.read(currentSynchronizedDataProvider);
                            ref.read(currentMessageSenderProvider).sendSynchronizedData(
                                  synchronizedData.copyWith(
                                    game: savedGames.games[nameText]!,
                                    connectedDevices:
                                        synchronizedData.connectedDevices.map((device) => device.copyWith(controlledPlayerId: null)).toList(),
                                  ),
                                );
                          }
                        : null,
                    child: gameHasBegun
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Öppna '),
                              CheatingIndicator(),
                            ],
                          )
                        : const Text('Öppna'),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: savedGames.games.containsKey(nameText)
                        ? () {
                            prefs.value!.setString(
                              'savedGames',
                              json.encode(
                                savedGames.copyWith(
                                  games: savedGames.games.entries //
                                      .where((entry) => entry.key != nameText)
                                      .toMap((entry) => entry),
                                ),
                              ),
                            );
                            ref.invalidate(currentSharedPreferencesProvider);
                          }
                        : null,
                    child: const Text('Radera'),
                  ),
                ),
              ],
            ),
          ],
        );
      }(),
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = '';
    nameController.addListener(() {
      if (nameText != nameController.text) {
        setState(() {
          nameText = nameController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
