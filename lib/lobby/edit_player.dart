import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/iterables.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/player_configuration.dart';

class EditPlayer extends ConsumerStatefulWidget {
  final int? playerId;

  const EditPlayer(this.playerId, {super.key});

  @override
  ConsumerState<EditPlayer> createState() => _EditPlayerState();
}

class _EditPlayerState extends ConsumerState<EditPlayer> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final configuration = ref.watch(gameConfigurationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playerId == null ? 'Skapa ny spelare' : 'Redigera spelare'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Namn'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Spelaren måste ha ett namn';
                }
                if (configuration.players.any((player) => player.name == value && player.id != widget.playerId)) {
                  return 'Namnet är upptaget av en annan spelare';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.playerId == null) {
                      ref.read(currentMessageSenderProvider).sendGameConfiguration(configuration.copyWith(players: [
                            ...configuration.players,
                            PlayerConfiguration(
                              id: count().where((i) => configuration.players.every((player) => player.id != i)).first as int,
                              name: nameController.text,
                            )
                          ]));
                    } else {
                      ref.read(currentMessageSenderProvider).sendGameConfiguration(configuration.copyWith(
                            players: configuration.players
                                .map((player) => player.id == widget.playerId //
                                    ? player.copyWith(name: nameController.text)
                                    : player)
                                .toList(),
                          ));
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ok'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.playerId == null ? '' : ref.read(gameConfigurationProvider).players.firstWhere((player) => player.id == widget.playerId).name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
