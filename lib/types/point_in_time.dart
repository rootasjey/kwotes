import "dart:convert";

import "package:kwotes/globals/utils.dart";

class PointInTime {
  PointInTime({
    required this.beforeCommonEra,
    required this.country,
    required this.city,
    required this.date,
    required this.dateEmpty,
  });

  /// The date is neggative.
  final bool beforeCommonEra;

  /// True if the Firestore [date] value is null or doesn't exist.
  /// In this app, the [date] property will never be null (null safety).
  ///
  /// This property doesn't exist in Firestore.
  final bool dateEmpty;

  /// Country where the event happened.
  final String country;

  /// City where the event happened.
  final String city;

  /// The date of the event.
  final DateTime date;

  PointInTime copyWith({
    bool? beforeCommonEra,
    String? country,
    String? city,
    DateTime? date,
    bool? dateEmpty,
  }) {
    return PointInTime(
      beforeCommonEra: beforeCommonEra ?? this.beforeCommonEra,
      country: country ?? this.country,
      city: city ?? this.city,
      date: date ?? this.date,
      dateEmpty: dateEmpty ?? this.dateEmpty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "before_common_era": beforeCommonEra,
      "country": country,
      "city": city,
      "date": date,
    };
  }

  factory PointInTime.empty() {
    return PointInTime(
      beforeCommonEra: false,
      country: "",
      city: "",
      date: DateTime.now(),
      dateEmpty: true,
    );
  }

  factory PointInTime.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return PointInTime.empty();
    }

    return PointInTime(
      beforeCommonEra: map["before_common_era"] ?? false,
      country: map["country"] ?? "",
      city: map["city"] ?? "",
      date: Utils.tictac.fromFirestore(map["date"]),
      dateEmpty: map["date"] == null ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PointInTime.fromJson(String source) =>
      PointInTime.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "PointInTime(beforeCommonEra: $beforeCommonEra, country: $country, "
        "city: $city, date: $date, dateEmpty: $dateEmpty)";
  }

  @override
  bool operator ==(covariant PointInTime other) {
    if (identical(this, other)) return true;

    return other.beforeCommonEra == beforeCommonEra &&
        other.country == country &&
        other.city == city &&
        other.date == date &&
        other.dateEmpty == dateEmpty;
  }

  @override
  int get hashCode {
    return beforeCommonEra.hashCode ^
        country.hashCode ^
        city.hashCode ^
        date.hashCode ^
        dateEmpty.hashCode;
  }
}
