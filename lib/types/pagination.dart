class Pagination {
  final bool hasNext;
  final int limit;
  final int nextSkip;
  final int skip;

  Pagination({this.hasNext, this.limit, this.nextSkip, this.skip});

  factory Pagination.fromJSON(Map<String, dynamic> json) {
    return Pagination(
      hasNext : json['hasNext'],
      limit   : json['limit'],
      nextSkip: json['nextSkip'],
      skip    : json['skip'],
    );
  }
}
