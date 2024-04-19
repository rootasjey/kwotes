import "package:flutter/widgets.dart";

class ThemeSettingsData {
  /// A class for theme page.
  const ThemeSettingsData({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.onTap,
  });

  /// True if this theme is selected.
  final bool selected;

  /// Title of the theme.
  final String title;

  /// Subtitle of the theme.
  final String subtitle;

  /// Icon of the theme.
  final IconData iconData;

  /// Callback fired when this theme is selected.
  final void Function()? onTap;

  ThemeSettingsData copyWith({
    bool? selected,
    String? title,
    String? subtitle,
    IconData? iconData,
    void Function()? onTap,
  }) {
    return ThemeSettingsData(
      selected: selected ?? this.selected,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconData: iconData ?? this.iconData,
      onTap: onTap ?? this.onTap,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "selected": selected,
      "title": title,
      "subtitle": subtitle,
      "iconData": iconData.codePoint,
    };
  }

  @override
  String toString() {
    return "ThemeSettingsData(selected: $selected, title: $title, subtitle: $subtitle, iconData: $iconData, onTap: $onTap)";
  }

  @override
  bool operator ==(covariant ThemeSettingsData other) {
    if (identical(this, other)) return true;

    return other.selected == selected &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.iconData == iconData &&
        other.onTap == onTap;
  }

  @override
  int get hashCode {
    return selected.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        iconData.hashCode ^
        onTap.hashCode;
  }
}
