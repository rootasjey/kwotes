import "dart:convert";

import "package:kwotes/types/image_credits.dart";

class ImageProperty {
  ImageProperty({
    required this.credits,
    required this.url,
  });

  ImageCredits credits;
  final String url;

  ImageProperty copyWith({
    ImageCredits? credits,
    String? url,
  }) {
    return ImageProperty(
      credits: credits ?? this.credits,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "credits": credits.toMap(),
    };
  }

  factory ImageProperty.empty() {
    return ImageProperty(
      credits: ImageCredits.empty(),
      url: "",
    );
  }

  factory ImageProperty.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ImageProperty.empty();
    }

    return ImageProperty(
      credits: ImageCredits.fromMap(map["credits"]),
      url: map["url"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageProperty.fromJson(String source) =>
      ImageProperty.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "ImageProperty(credits: $credits)";

  @override
  bool operator ==(covariant ImageProperty other) {
    if (identical(this, other)) return true;

    return other.credits == credits && other.url == url;
  }

  @override
  int get hashCode => credits.hashCode ^ url.hashCode;
}
