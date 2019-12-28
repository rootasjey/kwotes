class Reference {
  final String id;
  final String imgUrl;
  final String lang;
  final List<Reference> linkedRefs;
  final String name;
  final String promoUrl;
  final String subType;
  final String summary;
  final String type;
  final String url;

  Reference({
    this.id,
    this.imgUrl,
    this.lang,
    this.linkedRefs,
    this.name,
    this.promoUrl,
    this.subType,
    this.summary,
    this.type,
    this.url,
  });

  factory Reference.fromJSON(Map<String, dynamic> json) {
    List<Reference> _linkedRefs = [];

    if (json['linkedRefs'] != null) {
      for (var ref in json['linkedRefs']) {
        _linkedRefs.add(Reference.fromJSON(ref));
      }
    }

    return Reference(
      id          : json['id'],
      imgUrl      : json['imgUrl'],
      lang        : json['lang'],
      linkedRefs  : _linkedRefs,
      name        : json['name'],
      promoUrl    : json['promoUrl'],
      subType     : json['subType'],
      summary     : json['summary'],
      type        : json['type'],
      url         : json['url'],
    );
  }
}
