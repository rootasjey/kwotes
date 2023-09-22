import "package:flutter/material.dart";

/// Side menu item containing an icon leading an a text label.
/// It must also have a defined hover color and a route path.
class SideMenuItem {
  const SideMenuItem({
    required this.iconData,
    required this.label,
    required this.hoverColor,
    required this.routePath,
  });

  /// Icon to use as leading.
  final IconData iconData;

  /// Text value for this item.
  final String label;

  /// Hover color.
  final Color hoverColor;

  /// Route path.
  final String routePath;
}
