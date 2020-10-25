import 'package:figstyle/types/pagination.dart';
import 'package:figstyle/types/temp_quote.dart';

class DraftsResponse {
  Pagination pagination;
  List<TempQuote> entries;

  DraftsResponse({this.entries, this.pagination});

  factory DraftsResponse.fromJSON(Map<String, dynamic> json) {
    List<TempQuote> drafts = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        drafts.add(TempQuote.fromJSON(quote));
      }
    }

    return DraftsResponse(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: drafts,
    );
  }
}
