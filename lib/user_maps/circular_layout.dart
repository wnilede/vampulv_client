import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularLayout extends StatelessWidget {
  final List<Widget> children;
  final Widget? inside;
  final double rotationOffset;

  /// If true, the children will be sized as though the circles is inside them rather than they inside circles. Use this when you can guarantee that everything visible in the children fit inside the largest circle fitting inside theire constraints.
  final bool largerChildren;

  const CircularLayout({this.rotationOffset = 0, this.largerChildren = false, this.inside, required this.children, super.key})
      : assert(children.length > 0),
        assert(inside == null || children.length >= 3);

  @override
  Widget build(BuildContext context) {
    // The positions of the children are choosen to maximize their sizes while satisfying the following conditions:
    //  * the centers of the children have the same distance to the center of this widget.
    //  * the smallest circles containing the children have the same size and do not overlap.
    //  * the smallest circle containing all the children is inside this widget.
    return LayoutBuilder(builder: (context, constraints) {
      // The ratio between the radius of the children and the radius of the circle on which they lie.
      final sin = math.sin(math.pi / (children.length + 1));

      // The distance from the center of the widget that the centers of the children will be.
      final radius = math.min(constraints.maxHeight, constraints.maxWidth) / (1 + sin) / 2;

      // The radius of the circles circumscribing the children.
      final childRadius = radius * sin;

      // The side lengths of the children, assuming they are squares. Should be relatively easy to add calculations to acount for all rectangular children. Perhaps we could allow a list of width:height ratios to be passed in together with the children?
      final childSize = childRadius * math.sqrt2;

      // The side lengths of the child inside the circle.
      final centerChildSize = (radius - 2 * childRadius) * math.sqrt2;

      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // This is weird, but I could not figure out how to set the size of the stack in any other way.
          SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
          if (inside != null)
            Center(
              child: SizedBox(
                width: centerChildSize,
                height: centerChildSize,
                child: inside,
              ),
            ),
          ...children
              .asMap()
              .entries
              .map<Widget>((final indexPlayerPair) => Positioned(
                    top: (constraints.maxHeight - childSize) / 2 + radius * math.cos(rotationOffset + 2 * math.pi * indexPlayerPair.key / children.length),
                    left: (constraints.maxWidth - childSize) / 2 - radius * math.sin(rotationOffset + 2 * math.pi * indexPlayerPair.key / children.length),
                    child: SizedBox(
                      width: childSize,
                      height: childSize,
                      child: indexPlayerPair.value,
                    ),
                  ))
              .toList(),
        ],
      );
    });
  }
}
