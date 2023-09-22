import "dart:convert";

class SocialLinks {
  SocialLinks({
    this.artbooking = "",
    this.artstation = "",
    this.behance = "",
    this.curriculum = "",
    this.deviantart = "",
    this.discord = "",
    this.dribbble = "",
    this.facebook = "",
    this.github = "",
    this.instagram = "",
    this.linkedin = "",
    this.map = const {},
    this.other = "",
    this.patreon = "",
    this.profilePicture = "",
    this.socialMap = const {},
    this.tiktok = "",
    this.tipeee = "",
    this.tumblr = "",
    this.twitch = "",
    this.twitter = "",
    this.website = "",
    this.wikipedia = "",
    this.youtube = "",
  });

  /// All URLs in a map.
  Map<String, String> map = <String, String>{};

  /// Only social URLs in a map (without [image] for example).
  Map<String, String> socialMap = <String, String>{};

  final String artbooking;
  final String artstation;
  final String behance;
  final String curriculum;
  final String deviantart;
  final String discord;
  final String dribbble;
  final String facebook;
  final String github;
  final String instagram;
  final String linkedin;
  final String other;
  final String patreon;
  final String profilePicture;
  final String tiktok;
  final String tipeee;
  final String tumblr;
  final String twitch;
  final String twitter;
  final String website;
  final String wikipedia;
  final String youtube;

  static const artbookingString = "artbooking";
  static const artstationString = "artstation";
  static const behanceString = "behance";
  static const curriculumString = "curriculum";
  static const deviantartString = "deviantart";
  static const discordString = "discord";
  static const dribbbleString = "dribbble";
  static const facebookString = "facebook";
  static const githubString = "github";
  static const instagramString = "instagram";
  static const linkedinString = "linkedin";
  static const otherString = "other";
  static const patreonString = "patreon";
  static const profilePictureString = "profilePicture";
  static const tiktokString = "tiktok";
  static const tipeeeString = "tipeee";
  static const tumblrString = "tumblr";
  static const twitchString = "twitch";
  static const twitterString = "twitter";
  static const websiteString = "website";
  static const wikipediaString = "wikipedia";
  static const youtubeString = "youtube";

  SocialLinks copyWith({
    String? artbooking,
    String? artstation,
    String? behance,
    String? curriculum,
    String? deviantart,
    String? discord,
    String? dribbble,
    String? facebook,
    String? github,
    String? instagram,
    String? linkedin,
    String? other,
    String? patreon,
    Map<String, String>? map,
    Map<String, String>? socialMap,
    String? profilePicture,
    String? tiktok,
    String? tipeee,
    String? tumblr,
    String? twitch,
    String? twitter,
    String? website,
    String? wikipedia,
    String? youtube,
  }) {
    return SocialLinks(
      artbooking: artbooking ?? this.artbooking,
      artstation: artstation ?? this.artstation,
      behance: behance ?? this.behance,
      curriculum: curriculum ?? this.curriculum,
      deviantart: deviantart ?? this.deviantart,
      discord: discord ?? this.discord,
      dribbble: dribbble ?? this.dribbble,
      facebook: facebook ?? this.facebook,
      github: github ?? this.github,
      instagram: instagram ?? this.instagram,
      linkedin: linkedin ?? this.linkedin,
      map: map ?? this.map,
      socialMap: socialMap ?? this.socialMap,
      other: other ?? this.other,
      patreon: patreon ?? this.patreon,
      profilePicture: profilePicture ?? this.profilePicture,
      tiktok: tiktok ?? this.tiktok,
      tipeee: tipeee ?? this.tipeee,
      tumblr: tumblr ?? this.tumblr,
      twitch: twitch ?? this.twitch,
      twitter: twitter ?? this.twitter,
      website: website ?? this.website,
      wikipedia: wikipedia ?? this.wikipedia,
      youtube: youtube ?? this.youtube,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      artbookingString: artbooking,
      artstationString: artstation,
      behanceString: behance,
      curriculumString: curriculum,
      deviantartString: deviantart,
      discordString: discord,
      dribbbleString: dribbble,
      facebookString: facebook,
      githubString: github,
      instagramString: instagram,
      linkedinString: linkedin,
      otherString: other,
      patreonString: patreon,
      profilePictureString: profilePicture,
      tiktokString: tiktok,
      tipeeeString: tipeee,
      tumblrString: tumblr,
      twitchString: twitch,
      twitterString: twitter,
      websiteString: website,
      wikipediaString: wikipedia,
      youtubeString: youtube,
    };
  }

  factory SocialLinks.empty() {
    return SocialLinks(
      artbooking: "",
      artstation: "",
      behance: "",
      curriculum: "",
      deviantart: "",
      discord: "",
      dribbble: "",
      facebook: "",
      github: "",
      instagram: "",
      linkedin: "",
      map: {},
      socialMap: {},
      other: "",
      patreon: "",
      profilePicture: "",
      tiktok: "",
      tipeee: "",
      tumblr: "",
      twitch: "",
      twitter: "",
      website: "",
      wikipedia: "",
      youtube: "",
    );
  }

  Map<String, String> getAvailableLinks() {
    return Map.from(socialMap)..removeWhere((key, value) => value.isEmpty);
  }

  factory SocialLinks.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return SocialLinks.empty();
    }

    final dataMap = <String, String>{};
    final socialMap = <String, String>{};

    map.forEach((key, value) {
      dataMap[key] = value;

      if (key != "image") {
        socialMap[key] = value;
      }
    });

    return SocialLinks(
      artbooking: map[artbookingString] ?? "",
      artstation: map[artstationString] ?? "",
      behance: map[behanceString] ?? "",
      curriculum: map[curriculumString] ?? "",
      deviantart: map[deviantartString] ?? "",
      discord: map[discordString] ?? "",
      dribbble: map[dribbbleString] ?? "",
      facebook: map[facebookString] ?? "",
      github: map[githubString] ?? "",
      instagram: map[instagramString] ?? "",
      linkedin: map[linkedinString] ?? "",
      map: dataMap,
      socialMap: socialMap,
      other: map[otherString] ?? "",
      patreon: map[patreonString] ?? "",
      profilePicture: map[profilePictureString] ?? "",
      tiktok: map[tiktokString] ?? "",
      tipeee: map[tipeeeString] ?? "",
      tumblr: map[tumblrString] ?? "",
      twitch: map[twitchString] ?? "",
      twitter: map[twitterString] ?? "",
      website: map[websiteString] ?? "",
      wikipedia: map[wikipediaString] ?? "",
      youtube: map[youtubeString] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory SocialLinks.fromJson(String source) =>
      SocialLinks.fromMap(json.decode(source));

  @override
  String toString() {
    return "UserSocialLinks(artbooking: $artbooking, artstation: $artstation, "
        "behance: $behance, deviantart: $deviantart, discord: $discord, "
        "dribbble: $dribbble, facebook: $facebook, github: $github, "
        "instagram: $instagram, linkedin: $linkedin, other: $other, "
        "patreon: $patreon, profilePicture: $profilePicture, tiktok: $tiktok, "
        "tipeee: $tipeee, tumblr: $tumblr, twitch: $twitch, twitter: $twitter, "
        "website: $website, wikipedia: $wikipedia, youtube: $youtube)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SocialLinks &&
        other.artbooking == artbooking &&
        other.artstation == artstation &&
        other.behance == behance &&
        other.deviantart == deviantart &&
        other.discord == discord &&
        other.dribbble == dribbble &&
        other.facebook == facebook &&
        other.github == github &&
        other.instagram == instagram &&
        other.linkedin == linkedin &&
        other.patreon == patreon &&
        other.profilePicture == profilePicture &&
        other.tiktok == tiktok &&
        other.tipeee == tipeee &&
        other.tumblr == tumblr &&
        other.twitch == twitch &&
        other.twitter == twitter &&
        other.website == website &&
        other.wikipedia == wikipedia &&
        other.youtube == youtube;
  }

  @override
  int get hashCode {
    return artbooking.hashCode ^
        artstation.hashCode ^
        behance.hashCode ^
        deviantart.hashCode ^
        discord.hashCode ^
        dribbble.hashCode ^
        facebook.hashCode ^
        github.hashCode ^
        instagram.hashCode ^
        linkedin.hashCode ^
        other.hashCode ^
        patreon.hashCode ^
        profilePicture.hashCode ^
        tiktok.hashCode ^
        tipeee.hashCode ^
        tumblr.hashCode ^
        twitch.hashCode ^
        twitter.hashCode ^
        website.hashCode ^
        wikipedia.hashCode ^
        youtube.hashCode;
  }
}
