import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/date_helper.dart';

class Quotidian {
  final DateTime createdAt;
  final DateTime date;
  final String id;
  final String lang;
  final Quote quote;
  final DateTime updatedAt;

  Quotidian({
    this.createdAt,
    this.date,
    this.id,
    this.lang,
    this.quote,
    this.updatedAt,
  });

  factory Quotidian.empty() {
    return Quotidian(
      createdAt: DateTime.now(),
      date: DateTime.now(),
      id: '',
      lang: 'en',
      quote: Quote.empty(),
      updatedAt: DateTime.now(),
    );
  }

  factory Quotidian.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return Quotidian.empty();
    }

    return Quotidian(
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      date: DateHelper.fromFirestore(data['date']),
      id: data['id'] ?? '',
      lang: data['lang'] ?? 'en',
      quote: Quote.fromJSON(data['quote']),
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['createdAt'] = createdAt;
    json['date'] = date;
    json['id'] = id;
    json['lang'] = lang;
    json['quote'] = quote.toJSON();
    json['updatedAt'] = updatedAt;

    return json;
  }
}
