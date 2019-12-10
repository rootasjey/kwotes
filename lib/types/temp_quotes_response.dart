import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/temp_quote.dart';

class TempQuotesResponse {
  Pagination pagination;
  List<TempQuote> entries;

  TempQuotesResponse({this.entries, this.pagination});

  factory TempQuotesResponse.fromJSON(Map<String, dynamic> json) {
    List<TempQuote> quotes = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        quotes.add(TempQuote.fromJSON(quote));
      }
    }

    return TempQuotesResponse(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: quotes,
    );
  }
}
