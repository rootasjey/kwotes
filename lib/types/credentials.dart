import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Credentials {
  String email;
  String password;
  bool isLoadedFromFile = false;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/credentials');
  }

  Credentials({this.email, this.password});

  Map<String, dynamic> toJSON() {
    var map = Map<String, dynamic>();
    map['email'] = email;
    map['password'] = password;

    return map;
  }

  String toJSONString() {
    final json = toJSON();
    return jsonEncode(json);
  }

  factory Credentials.fromString(String str) {
    final json = jsonDecode(str);
    return Credentials.fromJSON(json);
  }

  factory Credentials.fromJSON(Map<String, dynamic> json) {
    return Credentials(
      email: json['email'],
      password: json['password'],
    );
  }

  static clearFile() async {
    final file = await _localFile;
    if (file != null) { await file.delete(); }
  }

  /// Return saved credentials from local file.
  static Future<Credentials> readFromFile() async {
    try {
      final file = await _localFile;
      final str = file.readAsStringSync();

      final savedCredentials = Credentials.fromString(str);
      savedCredentials.isLoadedFromFile = true;

      return savedCredentials;

    } catch (e) {
      return null;
    }
  }

  void saveToFile() async {
    final file = await _localFile;
    final str = toJSONString();
    await file.writeAsString(str);
  }
}
