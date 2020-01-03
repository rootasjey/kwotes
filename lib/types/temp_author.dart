class TempAuthor {
  final String imgUrl;
  final String job;
  final String name;
  final String summary;
  final String url;
  final String wikiUrl;

  TempAuthor({
    this.imgUrl,
    this.job,
    this.name,
    this.summary,
    this.url,
    this.wikiUrl,
  });

  factory TempAuthor.fromJSON(Map<String, dynamic> json) {
    return TempAuthor(
      imgUrl  : json['imgUrl'],
      job     : json['job'],
      name    : json['name'],
      summary : json['summary'],
      url     : json['url'],
      wikiUrl : json['wikiUrl'],
    );
  }
}
