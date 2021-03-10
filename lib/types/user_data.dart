import 'dart:convert';

class UserData {
  String email;
  String id;
  String imgUrl;
  String lang;
  String name;
  List<String> rights;
  String token;

  UserData({
    this.email = '',
    this.id = '',
    this.imgUrl = '',
    this.lang = '',
    this.name = '',
    this.rights = const [],
    this.token = '',
  });

  factory UserData.empty() {
    return UserData(
      email: '',
      id: '',
      imgUrl: '',
      lang: '',
      name: '',
      rights: [],
      token: '',
    );
  }

  factory UserData.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return UserData.empty();
    }

    List<String> rights = [];

    if (data['rights'] != null) {
      for (var right in data['rights']) {
        rights.add(right);
      }
    }

    return UserData(
      email: data['email'] ?? '',
      id: data['id'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      lang: data['lang'] ?? '',
      name: data['name'] ?? '',
      rights: rights,
      token: data['token'] ?? '',
    );
  }

  factory UserData.fromString(String str) {
    final json = jsonDecode(str);
    return UserData.fromJSON(json);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();
    List<String> jsonRights = [];

    for (var right in rights) {
      jsonRights.add(right);
    }

    json['email'] = email;
    json['id'] = id;
    json['imgUrl'] = imgUrl;
    json['lang'] = lang;
    json['name'] = name;
    json['rights'] = jsonRights;
    json['token'] = token;

    return json;
  }
}
