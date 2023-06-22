import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularLayout extends StatelessWidget {
  final List<Widget> children;

  const CircularLayout({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double radius = math.min(constraints.maxHeight, constraints.maxWidth) * 0.8;
      // Max side length a childs square can have so that we can guarantee that they don't overlap. Should be possible to make it larger.
      double childSize = math.sqrt2 * radius * math.pi / children.length;
      return Stack(
        children: children
            .asMap()
            .entries
            .map<Widget>((final indexPlayerPair) => Positioned(
                  top: constraints.maxHeight / 2 + radius * math.sin(math.pi * indexPlayerPair.key / children.length),
                  left: constraints.maxWidth / 2 + radius * math.cos(math.pi * indexPlayerPair.key / children.length),
                  child: SizedBox(
                    width: childSize,
                    height: childSize,
                    child: indexPlayerPair.value,
                  ),
                ))
            .toList(),
      );
    });
  }
}
