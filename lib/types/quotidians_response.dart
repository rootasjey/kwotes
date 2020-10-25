import 'package:figstyle/types/pagination.dart';
import 'package:figstyle/types/quotidian.dart';

class QuotidiansResponse {
  Pagination pagination;
  List<Quotidian> entries;

  QuotidiansResponse({this.entries, this.pagination});

  factory QuotidiansResponse.fromJSON(Map<String, dynamic> json) {
    List<Quotidian> quotidians = [];

    if (json['entries'] != null) {
      for (var quote in json['entries']) {
        quotidians.add(Quotidian.fromJSON(quote));
      }
    }

    return QuotidiansResponse(
      pagination: json['pagination'] != null ? Pagination.fromJSON(json['pagination']) : null,
      entries: quotidians,
    );
  }
}
