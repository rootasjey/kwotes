import 'pagination.dart';
import 'quote.dart';

class QuotesResponse {
  Pagination pagination;
  List<Quote> entries;

  QuotesResponse({this.entries, this.pagination});

  factory QuotesResponse.fromJSON(Map<String, dynamic> json) {
    List<Quote> quotes = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        quotes.add(Quote.fromJSON(quote));
      }
    }

    return QuotesResponse(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: quotes,
    );
  }
}
