import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/message_sender_provider.dart';
import 'package:vampulv/network/synchronized_data_provider.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/role_list_item.dart';
import 'package:vampulv/roles/role_type.dart';

class ChooseRoles extends ConsumerStatefulWidget {
  const ChooseRoles({super.key});

  @override
  ConsumerState<ChooseRoles> createState() => _ChooseRolesState();
}

class _ChooseRolesState extends ConsumerState<ChooseRoles> {
  bool selectedAmongAll = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    GameConfiguration gameConfiguration = ref.watch(currentSynchronizedDataProvider.select((synchronizedData) => synchronizedData.gameConfiguration));
    if (selectedIndex != null && (selectedAmongAll && selectedIndex! >= RoleType.values.length || !selectedAmongAll && selectedIndex! >= gameConfiguration.roles.length)) {
      selectedIndex = null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: ListView(
                      children: gameConfiguration.roles.indexed
                          .map((indexedRoleType) => GestureDetector(
                                onTap: () {
                                  selectRole(false, indexedRoleType.$1);
                                },
                                child: RoleListItem(indexedRoleType.$2, !selectedAmongAll && indexedRoleType.$1 == selectedIndex),
                              ))
                          .toList())),
              Expanded(
                  child: ListView(
                      children: RoleType.values.indexed
                          .map((indexedRoleType) => GestureDetector(
                                onTap: () {
                                  selectRole(true, indexedRoleType.$1);
                                },
                                child: RoleListItem(indexedRoleType.$2, selectedAmongAll && indexedRoleType.$1 == selectedIndex),
                              ))
                          .toList())),
            ],
          ),
        ),
        if (selectedIndex != null) Expanded(child: RoleTypeDescription(selectedAmongAll ? RoleType.values[selectedIndex!] : gameConfiguration.roles[selectedIndex!])),
        MaterialButton(
          onPressed: selectedIndex == null
              ? null
              : () {
                  ref.read(currentMessageSenderProvider).sendGameConfiguration(gameConfiguration.copyWith(
                        roles: (selectedAmongAll
                                ? gameConfiguration.roles.append(
                                    RoleType.values[selectedIndex!],
                                  )
                                : [
                                    ...gameConfiguration.roles.take(selectedIndex!),
                                    ...gameConfiguration.roles.skip(selectedIndex! + 1),
                                  ])
                            .toList(),
                      ));
                },
          child: Text(selectedIndex == null
              ? 'Lägg till / Ta bort'
              : selectedAmongAll
                  ? 'Lägg till'
                  : 'Ta bort'),
        ),
      ],
    );
  }

  selectRole(bool selectedAmongAll, int? selectedIndex) {
    setState(() {
      if (this.selectedAmongAll == selectedAmongAll && this.selectedIndex == selectedIndex) {
        this.selectedIndex = null;
      } else {
        this.selectedAmongAll = selectedAmongAll;
        this.selectedIndex = selectedIndex;
      }
    });
  }
}
