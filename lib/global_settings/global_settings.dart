import 'package:flutter/material.dart';
import 'package:vampulv/global_settings/save_load.dart';

class GlobalSettings extends StatelessWidget {
  final Widget drawer;

  const GlobalSettings({required this.drawer, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ändra spel'),
      ),
      drawer: drawer,
      body: ListView(
        children: [
          MaterialButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaveLoad()),
              );
            },
            child: const Text('Spara och öppna spel'),
          )
        ],
      ),
    );
  }
}
