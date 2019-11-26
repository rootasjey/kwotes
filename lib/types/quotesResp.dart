import 'pagination.dart';
import 'quote.dart';

class QuotesResp {
  Pagination pagination;
  List<Quote> entries;

  QuotesResp({this.entries, this.pagination});

  factory QuotesResp.fromJSON(Map<String, dynamic> json) {
    List<Quote> quotes = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        quotes.add(Quote.fromJSON(quote));
      }
    }

    return QuotesResp(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: quotes,
    );
  }
}
