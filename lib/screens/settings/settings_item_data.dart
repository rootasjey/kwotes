import "dart:convert";

import "package:flutter/widgets.dart";

class SettingsItemData {
  final String name;
  final String route;
  final bool isExternalLink;
  final String description;
  final bool enabled;
  final IconData? iconData;

  const SettingsItemData({
    required this.name,
    required this.route,
    this.isExternalLink = false,
    this.description = "",
    this.enabled = true,
    this.iconData,
  });

  SettingsItemData copyWith({
    String? name,
    String? route,
    bool? isExternalLink,
    String? description,
    bool? enabled,
    IconData? iconData,
  }) {
    return SettingsItemData(
      name: name ?? this.name,
      route: route ?? this.route,
      isExternalLink: isExternalLink ?? this.isExternalLink,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      iconData: iconData ?? this.iconData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "route": route,
      "isExternalLink": isExternalLink,
      "description": description,
      "enabled": enabled,
    };
  }

  factory SettingsItemData.fromMap(Map<String, dynamic> map) {
    return SettingsItemData(
      name: map["name"] ?? "",
      route: map["route"] ?? "",
      isExternalLink: map["isExternalLink"] ?? false,
      description: map["description"] ?? "",
      enabled: map["enabled"] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsItemData.fromJson(String source) =>
      SettingsItemData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "SettingsItemData(name: $name, route: $route, "
        "isExternalLink: $isExternalLink, description: $description, "
        "enabled: $enabled)";
  }

  @override
  bool operator ==(covariant SettingsItemData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.route == route &&
        other.isExternalLink == isExternalLink &&
        other.description == description &&
        other.enabled == enabled &&
        other.iconData == iconData;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        route.hashCode ^
        isExternalLink.hashCode ^
        description.hashCode ^
        enabled.hashCode ^
        iconData.hashCode;
  }
}
