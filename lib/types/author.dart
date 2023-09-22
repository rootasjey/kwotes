import "dart:convert";

import "package:kwotes/types/from_reference.dart";
import "package:kwotes/types/image_property.dart";
import "package:kwotes/types/point_in_time.dart";
import "package:kwotes/types/urls.dart";

class Author {
  Author({
    required this.fromReference,
    required this.birth,
    required this.death,
    required this.id,
    required this.image,
    required this.isFictional,
    required this.job,
    required this.name,
    required this.summary,
    required this.urls,
  });

  /// Useful if the author is fictional.
  final FromReference fromReference;

  /// Author's birth date.
  final PointInTime birth;

  /// Author's death date.
  final PointInTime death;

  /// Author's unique identifier.
  final String id;

  /// Author's image.
  final ImageProperty image;

  /// True if the author is fictional.
  final bool isFictional;

  /// Author's job title.
  final String job;

  /// Author's name.
  final String name;

  /// Author's summary.
  final String summary;

  /// Author's URLs (e.g. social networks).
  final Urls urls;

  /// Copy the current instance with passed new values.
  Author copyWith({
    FromReference? fromReference,
    PointInTime? birth,
    PointInTime? death,
    String? id,
    ImageProperty? image,
    bool? isFictional,
    String? job,
    String? name,
    String? summary,
    Urls? urls,
  }) {
    return Author(
      fromReference: fromReference ?? this.fromReference,
      birth: birth ?? this.birth,
      death: death ?? this.death,
      id: id ?? this.id,
      image: image ?? this.image,
      isFictional: isFictional ?? this.isFictional,
      job: job ?? this.job,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      urls: urls ?? this.urls,
    );
  }

  /// Convert the current instance to a map.
  Map<String, dynamic> toMap({
    bool minimal = false,
  }) {
    if (minimal) {
      return {
        "id": id,
        "name": name,
      };
    }

    return {
      "from_reference": fromReference.toMap(),
      "birth": birth.toMap(),
      "death": death.toMap(),
      "id": id,
      "image": image.toMap(),
      "is_fictional": isFictional,
      "job": job,
      "name": name,
      "summary": summary,
      "urls": urls.toMap(),
    };
  }

  /// Create an empty instance.
  factory Author.empty() {
    return Author(
      fromReference: FromReference.empty(),
      birth: PointInTime.empty(),
      death: PointInTime.empty(),
      id: "",
      image: ImageProperty.empty(),
      isFictional: false,
      job: "",
      name: "",
      summary: "",
      urls: Urls.empty(),
    );
  }

  /// Create an instance from a map.
  factory Author.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Author.empty();
    }

    return Author(
      fromReference: FromReference.fromMap(map["from_reference"]),
      birth: PointInTime.fromMap(map["birth"]),
      death: PointInTime.fromMap(map["death"]),
      id: map["id"] ?? "",
      image: ImageProperty.fromMap(map["image"]),
      isFictional: map["is_fictional"] ?? false,
      job: map["job"] ?? "",
      name: map["name"] ?? "",
      summary: map["summary"] ?? "",
      urls: Urls.fromMap(map["urls"]),
    );
  }

  /// Convert the current instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Create an instance from a JSON string.
  factory Author.fromJson(String source) =>
      Author.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "Author(fromReference: $fromReference, birth: $birth, death: $death,"
        "id: $id, image: $image, isFictional: $isFictional, job: $job, "
        "name: $name, summary: $summary, urls: $urls)";
  }

  @override
  bool operator ==(covariant Author other) {
    if (identical(this, other)) return true;

    return other.fromReference == fromReference &&
        other.birth == birth &&
        other.death == death &&
        other.id == id &&
        other.image == image &&
        other.isFictional == isFictional &&
        other.job == job &&
        other.name == name &&
        other.summary == summary &&
        other.urls == urls;
  }

  @override
  int get hashCode {
    return fromReference.hashCode ^
        birth.hashCode ^
        death.hashCode ^
        id.hashCode ^
        image.hashCode ^
        isFictional.hashCode ^
        job.hashCode ^
        name.hashCode ^
        summary.hashCode ^
        urls.hashCode;
  }
}
