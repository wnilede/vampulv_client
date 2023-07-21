import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Widget child;

  const ListItem({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}
