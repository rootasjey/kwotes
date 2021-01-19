import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class SideMenuItem {
  final PageRouteInfo destination;
  final IconData iconData;
  final String label;
  final Color hoverColor;

  const SideMenuItem({
    @required this.destination,
    @required this.iconData,
    @required this.label,
    @required this.hoverColor,
  });
}
