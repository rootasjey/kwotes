import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memorare/types/quote.dart';

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

  factory Quotidian.fromJSON(Map<String, dynamic> json) {
    return Quotidian(
      createdAt : (json['createdAt'] as Timestamp).toDate(),
      date      : (json['date'] as Timestamp).toDate(),
      id        : json['id'],
      lang      : json['lang'],
      quote     : Quote.fromJSON(json['quote']),
      updatedAt : (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();

    json['createdAt'] = createdAt;
    json['date']      = date;
    json['id']        = id;
    json['lang']      = lang;
    json['quote']     = quote.toJSON();
    json['updatedAt'] = updatedAt;

    return json;
  }
}
