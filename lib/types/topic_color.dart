import 'package:flutter/material.dart';

class TopicColor {
  final String name;
  final int decimal;
  final String hex;

  TopicColor({
    this.decimal,
    this.hex,
    this.name,
  });

  factory TopicColor.empty() {
    return TopicColor(
      decimal: 0,
      hex: 0.toRadixString(16),
      name: '',
    );
  }

  factory TopicColor.fromJSON(Map<String, dynamic> json) {
    if (json == null) {
      return TopicColor.empty();
    }

    int decimal = json['color'] ?? Colors.green.value;

    return TopicColor(
      decimal: decimal,
      hex: decimal.toRadixString(16),
      name: json['name'] ?? '',
    );
  }
}
