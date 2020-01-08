import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/quote.dart';

class QuotesList {
  final String id;
  String name;
  String description;
  Pagination pagination;
  final List<Quote> quotes;

  QuotesList({
    this.description,
    this.id,
    this.name,
    this.pagination,
    this.quotes
  });

  factory QuotesList.fromJSON(Map<String, dynamic> json) {
    List<Quote> _quotes = [];
    Pagination _pagination;

    if (json['quotes'] != null) {
      for (var jsonQuote in json['quotes']['entries']) {
        _quotes.add(Quote.fromJSON(jsonQuote));
      }

      _pagination = json['quotes']['pagination'] != null ?
        Pagination.fromJSON(json['quotes']['pagination']) :
        null;
    }

    return QuotesList(
      id: json['id'],
      description: json['description'],
      name: json['name'],
      pagination: _pagination,
      quotes: _quotes,
    );
  }
}
