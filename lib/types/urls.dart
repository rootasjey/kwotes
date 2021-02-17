class Urls {
  String affiliate;
  String amazon;
  String facebook;
  String image;
  String instagram;
  String netflix;
  String primeVideo;
  String twitch;
  String twitter;
  String website;
  String wikipedia;
  String youtube;

  Urls({
    this.affiliate = '',
    this.amazon = '',
    this.facebook = '',
    this.image = '',
    this.instagram = '',
    this.netflix = '',
    this.primeVideo = '',
    this.twitch = '',
    this.twitter = '',
    this.website = '',
    this.wikipedia = '',
    this.youtube = '',
  });

  bool areLinksEmpty() {
    return affiliate.isEmpty &&
        amazon.isEmpty &&
        facebook.isEmpty &&
        netflix.isEmpty &&
        instagram.isEmpty &&
        primeVideo.isEmpty &&
        twitch.isEmpty &&
        twitter.isEmpty &&
        website.isEmpty &&
        wikipedia.isEmpty &&
        youtube.isEmpty;
  }

  factory Urls.fromJSON(Map<String, dynamic> json) {
    return Urls(
      affiliate: json['affiliate'] ?? '',
      amazon: json['amazon'] ?? '',
      facebook: json['facebook'] ?? '',
      image: json['image'] ?? '',
      instagram: json['instagram'] ?? '',
      netflix: json['netflix'] ?? '',
      primeVideo: json['primeVideo'] ?? '',
      twitch: json['twitch'] ?? '',
      twitter: json['twitter'] ?? '',
      website: json['website'] ?? '',
      wikipedia: json['wikipedia'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['amazon'] = amazon;
    data['facebook'] = facebook;
    data['image'] = image;
    data['instagram'] = instagram;
    data['netflix'] = netflix;
    data['primeVideo'] = primeVideo;
    data['twitch'] = twitch;
    data['twitter'] = twitter;
    data['website'] = website;
    data['wikipedia'] = wikipedia;
    data['youtube'] = youtube;

    return data;
  }
}
