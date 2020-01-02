class Pagination {
  final bool hasNext;
  final int limit;
  final int nextSkip;
  final int skip;

  Pagination({
    this.hasNext = true,
    this.limit = 10,
    this.nextSkip = 0,
    this.skip = 0,
  });

  factory Pagination.fromJSON(Map<String, dynamic> json) {
    return Pagination(
      hasNext : json['hasNext'],
      limit   : json['limit'],
      nextSkip: json['nextSkip'],
      skip    : json['skip'],
    );
  }
}
