import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connection_settings.dart';

class ChangeServer extends ConsumerStatefulWidget {
  const ChangeServer({super.key});

  @override
  ConsumerState<ChangeServer> createState() => _ChangeServerState();
}

class _ChangeServerState extends ConsumerState<ChangeServer> {
  final _formKey = GlobalKey<FormState>();
  final adressController = TextEditingController();
  final roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ändra server'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: TextFormField(
                controller: adressController,
                decoration: const InputDecoration(labelText: 'Adress'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv in en adress';
                  }
                  if (Uri.tryParse(value) == null) {
                    return 'Adressen har inte ett godkänt format';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: TextFormField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'Rum'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv in ett rum';
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
                    ref
                        .read(cConnectionSettingsProvider.notifier)
                        .setState(ConnectionSettings(adress: adressController.text, room: roomController.text));
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
    final connectionSettings = ref.read(cConnectionSettingsProvider);
    adressController.text = connectionSettings.adress;
    roomController.text = connectionSettings.room;
  }

  @override
  void dispose() {
    adressController.dispose();
    roomController.dispose();
    super.dispose();
  }
}
