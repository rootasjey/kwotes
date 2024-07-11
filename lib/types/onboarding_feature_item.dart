import "dart:convert";

import "package:flutter/widgets.dart";

class OnboardingFeatureItem {
  OnboardingFeatureItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  OnboardingFeatureItem copyWith({
    String? title,
    String? description,
    IconData? icon,
  }) {
    return OnboardingFeatureItem(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "title": title,
      "description": description,
      "icon": icon.codePoint,
    };
  }

  factory OnboardingFeatureItem.fromMap(Map<String, dynamic> map) {
    return OnboardingFeatureItem(
      title: map["title"] as String,
      description: map["description"] as String,
      icon: IconData(map["icon"] as int, fontFamily: "MaterialIcons"),
    );
  }

  String toJson() => json.encode(toMap());

  factory OnboardingFeatureItem.fromJson(String source) =>
      OnboardingFeatureItem.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "OnboardingFeatureItem(title: $title, description: $description, icon: $icon)";

  @override
  bool operator ==(covariant OnboardingFeatureItem other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.icon == icon;
  }

  @override
  int get hashCode => title.hashCode ^ description.hashCode ^ icon.hashCode;
}
