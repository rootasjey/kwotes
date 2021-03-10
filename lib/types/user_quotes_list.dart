import 'package:figstyle/utils/date_helper.dart';

class UserQuotesList {
  final DateTime createdAt;
  String description;
  String iconUrl;
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

  factory UserQuotesList.empty() {
    return UserQuotesList(
      createdAt: DateTime.now(),
      iconUrl: '',
      id: '',
      name: '',
      updatedAt: DateTime.now(),
    );
  }

  factory UserQuotesList.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return UserQuotesList.empty();
    }

    return UserQuotesList(
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      iconUrl: data['iconUrl'] ?? '',
      id: data['id'] ?? '',
      isPublic: data['isPublic'] ?? false,
      description: data['description'] ?? '',
      name: data['name'] ?? '',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
    );
  }
}
