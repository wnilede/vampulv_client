import 'package:flutter/material.dart';
import 'package:vampulv/roles/role.dart';

class RoleListItem extends StatelessWidget {
  final RoleType role;
  final bool selected;

  const RoleListItem(this.role, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      isThreeLine: true,
      leading: const Icon(Icons.person),
      title: Text(role.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(role.description, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}
