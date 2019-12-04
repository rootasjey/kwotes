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
    this.email  = '',
    this.id     = '',
    this.imgUrl = '',
    this.lang   = '',
    this.name   = '',
    this.rights = const[],
    this.token  = '',
  });

  factory UserData.fromJSON(Map<String, dynamic> json) {
    List<String> rightsList = [];

    if (json['rights'] != null) {
      for (var right in json['rights']) {
        rightsList.add(right);
      }
    }

    return UserData(
      email : json['email'],
      id    : json['id'],
      imgUrl: json['imgUrl'],
      lang  : json['lang'],
      name  : json['name'],
      rights: rightsList,
      token : json['token'],
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

    json['email']   = email;
    json['id']      = id;
    json['imgUrl']  = imgUrl;
    json['lang']    = lang;
    json['name']    = name;
    json['rights']  = jsonRights;
    json['token']   = token;

    return json;
  }
}
