import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularLayout extends StatelessWidget {
  final List<Widget> children;
  final Widget? inside;
  final double rotationOffset;

  /// If true, the children will be sized as though the circles is inside them rather than they inside circles. Use this when you can guarantee that everything visible in the children fit inside the largest circle fitting inside theire constraints.
  final bool largerChildren;

  /// If true, the inside will be sized as though a circle is inside it rather than it inside a circle. Use this when you can guarantee that the inside fit inside the largest circle fitting inside it's constraints.
  final bool largerInside;

  const CircularLayout(
      {this.rotationOffset = 0, this.largerChildren = false, this.largerInside = false, this.inside, required this.children, super.key})
      : assert(children.length > 0, 'Circular layouts require at least one child.'),
        assert(inside == null || children.length >= 3, 'There can be no insides in circular layouts with fewer than 3 children.');

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

      // The side lengths of the children, assuming they are squares. Should be relatively easy to add calculations to account for all rectangular children. Perhaps we could allow a list of width:height ratios to be passed in together with the children?
      final childSize = childRadius * (largerChildren ? 2 : math.sqrt2);

      // The side lengths of the child inside the circle.
      final insideChildSize = (radius - childRadius) * (largerInside ? 2 : math.sqrt2);

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
                width: insideChildSize,
                height: insideChildSize,
                child: inside,
              ),
            ),
          ...children
              .asMap()
              .entries
              .map<Widget>((final indexPlayerPair) => Positioned(
                    top: (constraints.maxHeight - childSize) / 2 +
                        radius * math.cos(rotationOffset + 2 * math.pi * indexPlayerPair.key / children.length),
                    left: (constraints.maxWidth - childSize) / 2 -
                        radius * math.sin(rotationOffset + 2 * math.pi * indexPlayerPair.key / children.length),
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
