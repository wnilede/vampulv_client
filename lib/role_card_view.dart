import 'package:flutter/material.dart';
import 'package:vampulv/role_description.dart';
import 'package:vampulv/roles/role.dart';

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
              appBar: AppBar(),
              body: RoleDescription(role),
            ),
          ),
        );
      },
      child: SizedBox(
        width: 17,
        height: 23,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          child: Column(
            children: [
              const AspectRatio(
                aspectRatio: 1,
                child: Center(child: Icon(Icons.person)),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    role.displayName,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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
