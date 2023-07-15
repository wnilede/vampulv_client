import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/roles/role_type.dart';

class RoleCardView extends StatelessWidget {
  final RoleType role;

  const RoleCardView(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              appBar: AppBar(title: Text(role.displayName)),
              body: RoleDescription(role),
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
            borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                    role.displayName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 50,
                    ),
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
