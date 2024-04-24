import "dart:convert";

import "package:flutter/material.dart";
import "package:kwotes/types/enums/enum_feedback_type.dart";

class FeedbackChipData {
  FeedbackChipData({
    required this.label,
    required this.color,
    required this.type,
  });

  /// Title value.
  final String label;

  /// Chip color.
  final MaterialColor color;

  /// Feedback type.
  final EnumFeedbackType type;

  FeedbackChipData copyWith({
    String? label,
    MaterialColor? color,
    EnumFeedbackType? type,
  }) {
    return FeedbackChipData(
      label: label ?? this.label,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "titleValue": label,
      "color": color.value,
    };
  }

  factory FeedbackChipData.fromMap(Map<String, dynamic> map) {
    return FeedbackChipData(
      label: map["label"] ?? "",
      color: MaterialColor(map["color"] ?? 0, const <int, Color>{}),
      type: EnumFeedbackType.other,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedbackChipData.fromJson(String source) =>
      FeedbackChipData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "FeedbackChipData(label: $label, color: $color, type: $type)";

  @override
  bool operator ==(covariant FeedbackChipData other) {
    if (identical(this, other)) return true;

    return other.label == label && other.color == color && other.type == type;
  }

  @override
  int get hashCode => label.hashCode ^ color.hashCode ^ type.hashCode;
}
