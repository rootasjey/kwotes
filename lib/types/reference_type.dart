import "dart:convert";

import "package:kwotes/types/enums/enum_main_genre.dart";

class ReferenceType {
  ReferenceType({
    required this.primary,
    required this.secondary,
  });

  /// Primary type of this reference (e.g. Book, Film, Music, ...).
  String primary;

  /// Secondary type of this reference (e.g. Novel, Drama, Pop, ...).
  String secondary;

  ReferenceType copyWith({
    String? primary,
    String? secondary,
  }) {
    return ReferenceType(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "primary": primary,
      "secondary": secondary,
    };
  }

  factory ReferenceType.empty() {
    return ReferenceType(
      primary: "",
      secondary: "",
    );
  }

  factory ReferenceType.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ReferenceType.empty();
    }

    return ReferenceType(
      primary: map["primary"] ?? "",
      secondary: map["secondary"] ?? "",
    );
  }

  static EnumMainGenre getGenreFromString(String type) {
    switch (type) {
      case "article":
        return EnumMainGenre.article;
      case "blog":
        return EnumMainGenre.blog;
      case "book":
        return EnumMainGenre.book;
      case "comic":
        return EnumMainGenre.comic;
      case "film":
        return EnumMainGenre.film;
      case "graphic_novel":
        return EnumMainGenre.graphic_novel;
      case "game":
        return EnumMainGenre.game;
      case "music":
        return EnumMainGenre.music;
      case "news":
        return EnumMainGenre.news;
      case "novel":
        return EnumMainGenre.novel;
      case "other":
        return EnumMainGenre.other;
      case "painting":
        return EnumMainGenre.painting;
      case "paper":
        return EnumMainGenre.paper;
      case "play":
        return EnumMainGenre.play;
      case "photo":
        return EnumMainGenre.photo;
      case "podcast":
        return EnumMainGenre.podcast;
      case "poem":
        return EnumMainGenre.poem;
      case "post":
        return EnumMainGenre.post;
      case "tv_series":
        return EnumMainGenre.tv_series;
      case "video_game":
        return EnumMainGenre.video_game;
      case "video":
        return EnumMainGenre.video;
      case "website":
        return EnumMainGenre.website;
      default:
        return EnumMainGenre.other;
    }
  }

  String toJson() => json.encode(toMap());

  factory ReferenceType.fromJson(String source) =>
      ReferenceType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "ReferenceType(primary: $primary, secondary: $secondary)";

  @override
  bool operator ==(covariant ReferenceType other) {
    if (identical(this, other)) return true;

    return other.primary == primary && other.secondary == secondary;
  }

  @override
  int get hashCode => primary.hashCode ^ secondary.hashCode;
}
