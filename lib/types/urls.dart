class Urls {
  String amazon;
  String facebook;
  String image;
  String imdb;
  String instagram;
  String netflix;
  String primeVideo;
  String twitch;
  String twitter;
  String website;
  String wikipedia;
  String youtube;

  Urls({
    this.amazon = '',
    this.facebook = '',
    this.image = '',
    this.imdb = '',
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
    return amazon.isEmpty &&
        facebook.isEmpty &&
        imdb.isEmpty &&
        instagram.isEmpty &&
        netflix.isEmpty &&
        primeVideo.isEmpty &&
        twitch.isEmpty &&
        twitter.isEmpty &&
        website.isEmpty &&
        wikipedia.isEmpty &&
        youtube.isEmpty;
  }

  factory Urls.fromJSON(Map<String, dynamic> data) {
    return Urls(
      amazon: data['amazon'] ?? '',
      facebook: data['facebook'] ?? '',
      image: data['image'] ?? '',
      imdb: data['imdb'] ?? '',
      instagram: data['instagram'] ?? '',
      netflix: data['netflix'] ?? '',
      primeVideo: data['primeVideo'] ?? '',
      twitch: data['twitch'] ?? '',
      twitter: data['twitter'] ?? '',
      website: data['website'] ?? '',
      wikipedia: data['wikipedia'] ?? '',
      youtube: data['youtube'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['amazon'] = amazon;
    data['facebook'] = facebook;
    data['image'] = image;
    data['imdb'] = imdb;
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
