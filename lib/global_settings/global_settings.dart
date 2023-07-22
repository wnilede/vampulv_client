import 'package:flutter/material.dart';
import 'change_server.dart';
import 'save_load.dart';

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangeServer()),
              );
            },
            child: const Text('Ändra server'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaveLoad()),
              );
            },
            child: const Text('Spara och öppna spel'),
          ),
        ],
      ),
    );
  }
}
