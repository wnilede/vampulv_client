import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/role_list_item.dart';

class Information extends ConsumerWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(controlledPlayerProvider);
    return ListView(
      children: [
        if (player != null) const Text('Dina roller'),
        if (player != null)
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: player.roles
                  .map((role) => SizedBox(
                      width: 200,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => Scaffold(
                                appBar: AppBar(),
                                body: RoleDescription(role.type),
                              ),
                            ),
                          );
                        },
                        child: RoleListItem(role.type, false),
                      )))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
