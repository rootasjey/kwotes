import "dart:convert";

import "package:kwotes/types/enums/enum_data_ownership.dart";

class OwnershipData {
  /// A class for ownership data.
  /// Mainly used for filtering quotes with filter chips.
  OwnershipData({
    required this.ownership,
    required this.labelString,
    required this.tooltipString,
  });

  /// Selected quotes ownership (e.g. owned | all).
  final EnumDataOwnership ownership;

  /// Label string value.
  final String labelString;

  /// Tooltip string value.
  final String tooltipString;

  OwnershipData copyWith({
    EnumDataOwnership? ownership,
    String? labelString,
    String? tooltipString,
  }) {
    return OwnershipData(
      ownership: ownership ?? this.ownership,
      labelString: labelString ?? this.labelString,
      tooltipString: tooltipString ?? this.tooltipString,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "ownership": ownership.name,
      "label_string": labelString,
      "tooltip_string": tooltipString,
    };
  }

  factory OwnershipData.fromMap(Map<String, dynamic> map) {
    final ownership = EnumDataOwnership.values.firstWhere(
      (element) => element.name == map["ownership"],
      orElse: () => EnumDataOwnership.owned,
    );

    return OwnershipData(
      ownership: ownership,
      labelString: map["labelString"] as String,
      tooltipString: map["tooltipString"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OwnershipData.fromJson(String source) =>
      OwnershipData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "ChipOwnershipData(ownership: $ownership, labelString: $labelString, tooltipString: $tooltipString)";

  @override
  bool operator ==(covariant OwnershipData other) {
    if (identical(this, other)) return true;

    return other.ownership == ownership &&
        other.labelString == labelString &&
        other.tooltipString == tooltipString;
  }

  @override
  int get hashCode =>
      ownership.hashCode ^ labelString.hashCode ^ tooltipString.hashCode;
}
