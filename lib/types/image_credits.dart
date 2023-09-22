import "dart:convert";

import "package:kwotes/globals/utils.dart";

class ImageCredits {
  ImageCredits({
    required this.beforeCommonEra,
    required this.company,
    required this.date,
    required this.location,
    required this.name,
    required this.artist,
    required this.url,
  });

  bool beforeCommonEra;
  String company;
  DateTime date;
  String location;
  String name;
  String artist;
  String url;

  ImageCredits copyWith({
    bool? beforeCommonEra,
    String? company,
    DateTime? date,
    String? location,
    String? name,
    String? artist,
    String? url,
  }) {
    return ImageCredits(
      beforeCommonEra: beforeCommonEra ?? this.beforeCommonEra,
      company: company ?? this.company,
      date: date ?? this.date,
      location: location ?? this.location,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "before_common_era": beforeCommonEra,
      "company": company,
      "date": date,
      "location": location,
      "name": name,
      "artist": artist,
      "url": url,
    };
  }

  factory ImageCredits.empty() {
    return ImageCredits(
      beforeCommonEra: false,
      company: "",
      date: DateTime.now(),
      location: "",
      name: "",
      artist: "",
      url: "",
    );
  }

  factory ImageCredits.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ImageCredits.empty();
    }

    return ImageCredits(
      beforeCommonEra: map["before_common_era"] ?? false,
      company: map["company"] ?? "",
      date: Utils.tictac.fromFirestore(map["date"]),
      location: map["location"] ?? "",
      name: map["name"] ?? "",
      artist: map["artist"] ?? "",
      url: map["url"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageCredits.fromJson(String source) =>
      ImageCredits.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "ImageCredits(beforeCommonEra: $beforeCommonEra, company: $company, "
        "date: $date, location: $location, name: $name, "
        "artist: $artist, url: $url)";
  }

  @override
  bool operator ==(covariant ImageCredits other) {
    if (identical(this, other)) return true;

    return other.beforeCommonEra == beforeCommonEra &&
        other.company == company &&
        other.date == date &&
        other.location == location &&
        other.name == name &&
        other.artist == artist &&
        other.url == url;
  }

  @override
  int get hashCode {
    return beforeCommonEra.hashCode ^
        company.hashCode ^
        date.hashCode ^
        location.hashCode ^
        name.hashCode ^
        artist.hashCode ^
        url.hashCode;
  }
}
