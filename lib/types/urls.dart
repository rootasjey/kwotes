class Urls {
  final String affiliate;
  final String image;
  final String website;
  final String wikipedia;

  Urls({
    this.affiliate  = '',
    this.image      = '',
    this.website    = '',
    this.wikipedia  = '',
  });

  factory Urls.fromJSON(Map<String, dynamic> json) {
    return Urls(
      affiliate : json['affiliate'] ?? '',
      image     : json['image']     ?? '',
      website   : json['website']   ?? '',
      wikipedia : json['wikipedia'] ?? '',
    );
  }
}
