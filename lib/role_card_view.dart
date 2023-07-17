import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';

class RoleCardView extends StatelessWidget {
  final RoleType? roleType;
  final Role? role;

  const RoleCardView({this.roleType, this.role, super.key})
      : assert(
          (role == null) != (roleType == null),
          'Exactly one of role and roleType must be null when creating RoleCardView.',
        );

  @override
  Widget build(BuildContext context) {
    final roleType = this.roleType ?? role!.type;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              appBar: AppBar(title: const Text('Rolldetaljer')),
              body: role == null ? RoleTypeDescription(roleType) : RoleDescription(role!),
            ),
          ),
        );
      },
      child: FittedBox(
        child: Container(
          width: 170,
          height: 230,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: FittedBox(child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSecondary)),
              ),
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    roleType.displayName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
