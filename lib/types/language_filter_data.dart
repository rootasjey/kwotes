import "dart:convert";

import "package:flutter/widgets.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class LanguageFilterData {
  LanguageFilterData({
    required this.language,
    this.iconData,
    this.tooltipString = "",
    this.labelString = "",
  });

  /// Language (e.g. English, Français).
  final EnumLanguageSelection language;

  /// Icon data of this language.
  final IconData? iconData;

  /// Tooltip string value.
  final String tooltipString;

  /// Label string value.
  final String labelString;

  LanguageFilterData copyWith({
    EnumLanguageSelection? language,
    IconData? iconData,
    String? tooltipString,
    String? labelString,
  }) {
    return LanguageFilterData(
      language: language ?? this.language,
      iconData: iconData ?? this.iconData,
      tooltipString: tooltipString ?? this.tooltipString,
      labelString: labelString ?? this.labelString,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "language": language,
      "tooltip_string": tooltipString,
      "label_string": labelString,
    };
  }

  factory LanguageFilterData.fromMap(Map<String, dynamic> map) {
    final language = EnumLanguageSelection.values.firstWhere(
      (EnumLanguageSelection x) => x.name == map["language"],
      orElse: () => EnumLanguageSelection.all,
    );

    return LanguageFilterData(
      language: language,
      tooltipString: map["tooltip_string"] ?? "",
      labelString: map["label_string"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory LanguageFilterData.fromJson(String source) =>
      LanguageFilterData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "LanguageData(language: $language, iconData: $iconData, "
        "tooltipString: $tooltipString, labelString: $labelString)";
  }

  @override
  bool operator ==(covariant LanguageFilterData other) {
    if (identical(this, other)) return true;

    return other.language == language &&
        other.iconData == iconData &&
        other.tooltipString == tooltipString &&
        other.labelString == labelString;
  }

  @override
  int get hashCode {
    return language.hashCode ^
        iconData.hashCode ^
        tooltipString.hashCode ^
        labelString.hashCode;
  }
}
