import "dart:convert";

class Urls {
  Urls({
    required this.amazon,
    required this.facebook,
    required this.image,
    required this.imdb,
    required this.instagram,
    required this.netflix,
    required this.primeVideo,
    required this.twitch,
    required this.twitter,
    required this.website,
    required this.wikipedia,
    required this.youtube,
  });

  final String amazon;
  final String facebook;
  final String image;
  final String imdb;
  final String instagram;
  final String netflix;
  final String primeVideo;
  final String twitch;
  final String twitter;
  final String website;
  final String wikipedia;
  final String youtube;

  /// Get the value for the passed key.
  String getValue(String key) {
    switch (key) {
      case "amazon":
        return amazon;
      case "facebook":
        return facebook;
      case "image":
        return image;
      case "imdb":
        return imdb;
      case "instagram":
        return instagram;
      case "netflix":
        return netflix;
      case "primeVideo":
        return primeVideo;
      case "twitch":
        return twitch;
      case "twitter":
        return twitter;
      case "website":
        return website;
      case "wikipedia":
        return wikipedia;
      case "youtube":
        return youtube;
      default:
        return "";
    }
  }

  /// Copy the current object with passed new values.
  Urls copyWith({
    String? amazon,
    String? facebook,
    String? image,
    String? imdb,
    String? instagram,
    String? netflix,
    String? primeVideo,
    String? twitch,
    String? twitter,
    String? website,
    String? wikipedia,
    String? youtube,
  }) {
    return Urls(
      amazon: amazon ?? this.amazon,
      facebook: facebook ?? this.facebook,
      image: image ?? this.image,
      imdb: imdb ?? this.imdb,
      instagram: instagram ?? this.instagram,
      netflix: netflix ?? this.netflix,
      primeVideo: primeVideo ?? this.primeVideo,
      twitch: twitch ?? this.twitch,
      twitter: twitter ?? this.twitter,
      website: website ?? this.website,
      wikipedia: wikipedia ?? this.wikipedia,
      youtube: youtube ?? this.youtube,
    );
  }

  /// Copy the current object targeting the passed key.
  Urls copyWithKey({required String key, required String value}) {
    return Urls(
      amazon: key == "amazon" ? value : amazon,
      facebook: key == "facebook" ? value : facebook,
      image: key == "image" ? value : image,
      imdb: key == "imdb" ? value : imdb,
      instagram: key == "instagram" ? value : instagram,
      netflix: key == "netflix" ? value : netflix,
      primeVideo: key == "primeVideo" ? value : primeVideo,
      twitch: key == "twitch" ? value : twitch,
      twitter: key == "twitter" ? value : twitter,
      website: key == "website" ? value : website,
      wikipedia: key == "wikipedia" ? value : wikipedia,
      youtube: key == "youtube" ? value : youtube,
    );
  }

  /// Convert the current instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "amazon": amazon,
      "facebook": facebook,
      "image": image,
      "imdb": imdb,
      "instagram": instagram,
      "netflix": netflix,
      "prime_video": primeVideo,
      "twitch": twitch,
      "twitter": twitter,
      "website": website,
      "wikipedia": wikipedia,
      "youtube": youtube,
    };
  }

  /// Create an empty instance.
  factory Urls.empty() {
    return Urls(
      amazon: "",
      facebook: "",
      image: "",
      imdb: "",
      instagram: "",
      netflix: "",
      primeVideo: "",
      twitch: "",
      twitter: "",
      website: "",
      wikipedia: "",
      youtube: "",
    );
  }

  /// Create an instance from a map.
  factory Urls.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Urls.empty();
    }

    return Urls(
      amazon: map["amazon"] ?? "",
      facebook: map["facebook"] ?? "",
      image: map["image"] ?? "",
      imdb: map["imdb"] ?? "",
      instagram: map["instagram"] ?? "",
      netflix: map["netflix"] ?? "",
      primeVideo: map["prime_video"] ?? "",
      twitch: map["twitch"] ?? "",
      twitter: map["twitter"] ?? "",
      website: map["website"] ?? "",
      wikipedia: map["wikipedia"] ?? "",
      youtube: map["youtube"] ?? "",
    );
  }

  /// Convert the current instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Create an instance from a JSON string.
  factory Urls.fromJson(String source) =>
      Urls.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "Urls(amazon: $amazon, facebook: $facebook, image: $image, "
        "imdb: $imdb, instagram: $instagram, netflix: $netflix, "
        "primeVideo: $primeVideo, twitch: $twitch, twitter: $twitter, "
        "website: $website, wikipedia: $wikipedia, youtube: $youtube)";
  }

  @override
  bool operator ==(covariant Urls other) {
    if (identical(this, other)) return true;

    return other.amazon == amazon &&
        other.facebook == facebook &&
        other.image == image &&
        other.imdb == imdb &&
        other.instagram == instagram &&
        other.netflix == netflix &&
        other.primeVideo == primeVideo &&
        other.twitch == twitch &&
        other.twitter == twitter &&
        other.website == website &&
        other.wikipedia == wikipedia &&
        other.youtube == youtube;
  }

  @override
  int get hashCode {
    return amazon.hashCode ^
        facebook.hashCode ^
        image.hashCode ^
        imdb.hashCode ^
        instagram.hashCode ^
        netflix.hashCode ^
        primeVideo.hashCode ^
        twitch.hashCode ^
        twitter.hashCode ^
        website.hashCode ^
        wikipedia.hashCode ^
        youtube.hashCode;
  }
}
