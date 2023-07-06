import 'package:flutter/material.dart';
import 'package:vampulv/roles/role.dart';

class RoleDescription extends StatelessWidget {
  final RoleType role;

  const RoleDescription(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          role.displayName,
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          role.description,
          style: theme.textTheme.titleMedium,
        ),
        Text(
          role.detailedDescription,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
