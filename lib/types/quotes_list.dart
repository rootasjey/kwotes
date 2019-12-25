import 'package:memorare/types/quote.dart';

class QuotesList {
  final String id;
  String name;
  String description;
  final List<Quote> quotes;

  QuotesList({
    this.description,
    this.id,
    this.name,
    this.quotes
  });

  factory QuotesList.fromJSON(Map<String, dynamic> json) {
    List<Quote> _quotes = [];

    if (json['quotes'] != null) {
      for (var jsonQuote in json['quotes']['entries']) {
        _quotes.add(Quote.fromJSON(jsonQuote));
      }
    }

    return QuotesList(
      id: json['id'],
      description: json['description'],
      name: json['name'],
      quotes: _quotes,
    );
  }
}
