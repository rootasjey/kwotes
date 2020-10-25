import 'package:figstyle/types/pagination.dart';
import 'package:figstyle/types/quotes_list.dart';

class QuotesListsResponse {
  Pagination pagination;
  List<QuotesList> entries;

  QuotesListsResponse({this.entries, this.pagination});

  factory QuotesListsResponse.fromJSON(Map<String, dynamic> json) {
    List<QuotesList> quotesLists = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        quotesLists.add(QuotesList.fromJSON(quote));
      }
    }

    return QuotesListsResponse(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: quotesLists,
    );
  }
}
