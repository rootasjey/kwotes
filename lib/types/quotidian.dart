import 'package:memorare/types/quote.dart';

class Quotidian {
  final String id;
  final Quote quote;

  Quotidian({this.id, this.quote});

  factory Quotidian.fromJSON(Map<String, dynamic> json) {
    return Quotidian(
      id: json['id'],
      quote: Quote.fromJSON(json['quote']),
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['id']    = id;
    json['quote'] = quote.toJSON();

    return json;
  }
}
