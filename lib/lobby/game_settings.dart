import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';

class GameSettings extends ConsumerStatefulWidget {
  const GameSettings({super.key});

  @override
  ConsumerState<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends ConsumerState<GameSettings> {
  final _formKey = GlobalKey<FormState>();
  final livesController = TextEditingController();
  final rolesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final configuration = ref.watch(gameConfigurationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar spel'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: TextFormField(
                controller: livesController,
                decoration: const InputDecoration(labelText: 'Liv'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 2,
                validator: (value) {
                  if (value == null) {
                    return 'Spelarna måste ha minst ett liv var';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return 'Måste vara ett heltal';
                  }
                  if (intValue <= 0) {
                    return 'Spelarna måste ha minst ett liv var';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: TextFormField(
                controller: rolesController,
                decoration: const InputDecoration(labelText: 'Roller'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 2,
                validator: (value) {
                  if (value == null) {
                    return 'Spelarna måste ha minst en roll var';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return 'Måste vara ett heltal';
                  }
                  if (intValue <= 0) {
                    return 'Spelarna måste ha minst en roll var';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(currentMessageSenderProvider).sendGameConfiguration(configuration.copyWith(
                          maxLives: int.parse(livesController.text),
                          rolesPerPlayer: int.parse(rolesController.text),
                        ));
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
    livesController.text = ref.read(gameConfigurationProvider).maxLives.toString();
    rolesController.text = ref.read(gameConfigurationProvider).rolesPerPlayer.toString();
  }

  @override
  void dispose() {
    livesController.dispose();
    rolesController.dispose();
    super.dispose();
  }
}
