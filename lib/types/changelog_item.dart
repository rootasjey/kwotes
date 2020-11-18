import 'package:flutter/material.dart';

class ChangelogItem {
  final Widget title;
  final Widget subtitle;
  final DateTime date;
  bool isExpanded;

  Widget child;

  ChangelogItem({
    @required this.title,
    this.subtitle,
    this.date,
    @required this.child,
    this.isExpanded = false,
  });
}
