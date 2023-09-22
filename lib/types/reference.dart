import "dart:convert";

import "package:kwotes/types/image_property.dart";
import "package:kwotes/types/reference_type.dart";
import "package:kwotes/types/release.dart";
import "package:kwotes/types/urls.dart";

/// Reference data model.
class Reference {
  Reference({
    required this.release,
    required this.id,
    required this.image,
    required this.language,
    required this.name,
    required this.summary,
    required this.urls,
    required this.type,
  });

  /// When this reference was released.
  final Release release;

  /// Unique identifier of this reference.
  final String id;

  /// Image properties of this reference.
  final ImageProperty image;

  /// Original language of this reference.
  final String language;

  /// Name of this reference.
  final String name;

  /// Summary of this reference.
  final String summary;

  /// Type of this reference.
  final ReferenceType type;

  /// Urls of this reference (e.g. Wikipedia, website).
  final Urls urls;

  Reference copyWith({
    Release? release,
    String? id,
    ImageProperty? image,
    String? language,
    String? name,
    String? summary,
    ReferenceType? type,
    Urls? urls,
  }) {
    return Reference(
      release: release ?? this.release,
      id: id ?? this.id,
      image: image ?? this.image,
      language: language ?? this.language,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      type: type ?? this.type,
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

    return <String, dynamic>{
      "release": release.toMap(),
      "id": id,
      "image": image.toMap(),
      "language": language,
      "name": name,
      "summary": summary,
      "type": type.toMap(),
      "urls": urls.toMap(),
    };
  }

  /// Create an empty instance.
  factory Reference.empty() {
    return Reference(
      release: Release.empty(),
      id: "",
      image: ImageProperty.empty(),
      language: "",
      name: "",
      summary: "",
      urls: Urls.empty(),
      type: ReferenceType.empty(),
    );
  }

  factory Reference.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Reference.empty();

    return Reference(
      release: Release.fromMap(map["release"]),
      id: map["id"] ?? "",
      image: ImageProperty.fromMap(map["image"]),
      language: map["language"] ?? "",
      name: map["name"] ?? "",
      summary: map["summary"] ?? "",
      type: ReferenceType.fromMap(map["type"]),
      urls: Urls.fromMap(map["urls"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory Reference.fromJson(String source) =>
      Reference.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "Reference("
        "release: $release, id: $id, image: $image, lang: $language, "
        "name: $name, summary: $summary, urls: $urls)";
  }

  @override
  bool operator ==(covariant Reference other) {
    if (identical(this, other)) return true;

    return other.release == release &&
        other.id == id &&
        other.image == image &&
        other.language == language &&
        other.name == name &&
        other.summary == summary &&
        other.type == type &&
        other.urls == urls;
  }

  @override
  int get hashCode {
    return release.hashCode ^
        id.hashCode ^
        image.hashCode ^
        language.hashCode ^
        name.hashCode ^
        summary.hashCode ^
        type.hashCode ^
        urls.hashCode;
  }
}
