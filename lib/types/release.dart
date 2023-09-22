import "dart:convert";

import "package:kwotes/globals/utils.dart";

class Release {
  Release({
    required this.original,
    required this.beforeCommonEra,
    required this.dateEmpty,
  });

  /// Original release.
  DateTime original;

  /// True if the date is negative.
  bool beforeCommonEra;

  /// True if the Firestore [date] value is null or doesn't exist.
  /// In this app, the [date] property will never be null (null safety).
  ///
  /// This property doesn't exist in Firestore.
  bool dateEmpty;

  Release copyWith({
    DateTime? original,
    bool? beforeCommonEra,
    bool? dateEmpty,
  }) {
    return Release(
      original: original ?? this.original,
      beforeCommonEra: beforeCommonEra ?? this.beforeCommonEra,
      dateEmpty: dateEmpty ?? this.dateEmpty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "original": original,
      "before_common_era": beforeCommonEra,
    };
  }

  factory Release.empty() {
    return Release(
      original: DateTime.now(),
      beforeCommonEra: false,
      dateEmpty: true,
    );
  }

  factory Release.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Release.empty();

    return Release(
      original: Utils.tictac.fromFirestore(map["original"]),
      beforeCommonEra: map["before_common_era"] ?? false,
      dateEmpty: map["original"] == null ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Release.fromJson(String source) =>
      Release.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "Release(original: $original, beforeCommonEra: $beforeCommonEra, dateEmpty: $dateEmpty)";

  @override
  bool operator ==(covariant Release other) {
    if (identical(this, other)) return true;

    return other.original == original &&
        other.beforeCommonEra == beforeCommonEra &&
        other.dateEmpty == dateEmpty;
  }

  @override
  int get hashCode =>
      original.hashCode ^ beforeCommonEra.hashCode ^ dateEmpty.hashCode;
}
