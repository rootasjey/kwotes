import "package:flutter/widgets.dart";

/// Credit item data.
class CreditItemData {
  /// Credit's title.
  final String title;

  /// Credit's subtitle.
  final String subtitle;

  /// Credit's link.
  final String link;

  final IconData? iconData;

  /// Credit item data to build tile.
  CreditItemData({
    required this.title,
    required this.subtitle,
    required this.link,
    this.iconData,
  });
}
