class Urls {
  String affiliate;
  String amazon;
  String facebook;
  String image;
  String netflix;
  String primeVideo;
  String twitch;
  String twitter;
  String website;
  String wikipedia;
  String youtube;

  Urls({
    this.affiliate  = '',
    this.amazon     = '',
    this.facebook   = '',
    this.image      = '',
    this.netflix    = '',
    this.primeVideo = '',
    this.twitch     = '',
    this.twitter    = '',
    this.website    = '',
    this.wikipedia  = '',
    this.youtube    = '',
  });

  factory Urls.fromJSON(Map<String, dynamic> json) {
    return Urls(
      affiliate   : json['affiliate']   ?? '',
      amazon      : json['amazon']      ?? '',
      facebook    : json['facebook']    ?? '',
      image       : json['image']       ?? '',
      netflix     : json['netflix']     ?? '',
      primeVideo  : json['primeVideo']  ?? '',
      twitch      : json['twitch']      ?? '',
      twitter     : json['twitter']     ?? '',
      website     : json['website']     ?? '',
      wikipedia   : json['wikipedia']   ?? '',
      youtube     : json['youtube']     ?? '',
    );
  }
}
