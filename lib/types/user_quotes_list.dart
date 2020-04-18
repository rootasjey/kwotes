import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuotesList {
  final DateTime createdAt;
  String description;
  final String iconUrl;
  final String id;
  String name;
  bool isPublic;
  final DateTime updatedAt;

  UserQuotesList({
    this.createdAt,
    this.description,
    this.iconUrl,
    this.id,
    this.isPublic,
    this.name,
    this.updatedAt,
  });

  factory UserQuotesList.fromJSON(Map<String, dynamic> json) {
    return UserQuotesList(
      createdAt   : (json['createdAt'] as Timestamp).toDate(),
      iconUrl     : json['iconUrl'] ?? '',
      id          : json['id'],
      isPublic    : json['isPublic'],
      description : json['description'] ?? '',
      name        : json['name'] ?? '',
      updatedAt   : (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
