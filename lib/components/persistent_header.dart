import 'package:flutter/material.dart';

class PersistentHeader extends SliverPersistentHeaderDelegate {
  /// You should set the color according to your app's theme (light/dark).
  final Color color;

  /// The z-coordinate at which to place this header.
  /// This controls the size of the shadow below the header.
  final double elevation;

  /// This child container's height.
  /// Doesn't change the header's height
  /// (See minExtent & maxExtent getters for the later).
  final double height;

  /// The empty space that surrounds the header.
  final EdgeInsets margin;

  /// The [child] contained by the container.
  final Widget child;

  PersistentHeader({
    this.color = Colors.white,
    @required this.child,
    this.elevation = 5.0,
    this.height = 56.0,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: height,
      child: Card(
        margin: margin,
        color: color,
        elevation: elevation,
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
