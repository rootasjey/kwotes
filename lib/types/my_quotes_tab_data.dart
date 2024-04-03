import "dart:convert";

import "package:flutter/widgets.dart";
import "package:kwotes/types/enums/enum_my_quotes_tab.dart";

class MyQuotesTabData {
  final String textLabel;
  final EnumMyQuotesTab tab;
  final Color selectedColor;
  MyQuotesTabData({
    required this.textLabel,
    required this.tab,
    required this.selectedColor,
  });

  MyQuotesTabData copyWith({
    String? textLabel,
    EnumMyQuotesTab? tab,
    Color? selectedColor,
  }) {
    return MyQuotesTabData(
      textLabel: textLabel ?? this.textLabel,
      tab: tab ?? this.tab,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "textLabel": textLabel,
      "tab": tab.name,
      "selectedColor": selectedColor.value,
    };
  }

  factory MyQuotesTabData.fromMap(Map<String, dynamic> map) {
    return MyQuotesTabData(
      textLabel: map["textLabel"] as String,
      tab: EnumMyQuotesTab.values.firstWhere(
          (element) => element.name == map["tab"],
          orElse: () => EnumMyQuotesTab.drafts),
      selectedColor: Color(map["selectedColor"] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory MyQuotesTabData.fromJson(String source) =>
      MyQuotesTabData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "MyQuotesTabData(textLabel: $textLabel, tab: $tab, selectedColor: $selectedColor)";

  @override
  bool operator ==(covariant MyQuotesTabData other) {
    if (identical(this, other)) return true;

    return other.textLabel == textLabel &&
        other.tab == tab &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode =>
      textLabel.hashCode ^ tab.hashCode ^ selectedColor.hashCode;
}
