import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memorare/data/queries.dart';
import 'package:path_provider/path_provider.dart';

import '../types/user_data.dart';

class UserDataModel extends ChangeNotifier {
  final String _accountFileName = 'account';

  UserData _userData;
  bool _isAuthenticated = false;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_accountFileName');
  }

  /// True if the current user is authenticated.
  bool get isAuthenticated => _isAuthenticated;

  /// User's data.
  UserData get data => _userData;

  UserDataModel({UserData data}) {
    if (data == null) {
      _userData = new UserData();
    }
  }

  bool canI(String action) {
    if (_userData == null) { return false; }

    String right = '';

    if (action.toLowerCase() == 'managequote') {
      right = 'user:managequote';

    } else if (action.toLowerCase() == 'managequotidian') {
      right = 'user:managequotidian';
    } else if (action.toLowerCase() == 'manageauthor') {
      right = 'user:manageauthor';
    }

    return _userData.rights.contains(right);
  }

  /// Clear user's data.
  void clear() {
    _userData = new UserData();
    _isAuthenticated = false;
    clearFile();
    notifyListeners();
  }

  void clearFile() async {
    final file = await _localFile;
    if (file != null) { await file.delete(); }
  }

  Future readFromFile() async {
    try {
      final file = await _localFile;
      final str = file.readAsStringSync();

      _userData = UserData.fromString(str);

      if (_userData != null) {
        setAuthenticated(true);
      }

    } catch (e) {}
  }

  Future fetchAndUpdate(BuildContext context) {
    return Queries.userData(context)
    .then((dataResp) {
      update(dataResp);
      saveToFile(_userData.toJSON());
    });
  }

  void saveToFile(Map<String, dynamic> json) async {
    final file = await _localFile;
    final str = jsonEncode(json);
    await file.writeAsString(str);
  }

  /// Update user's authentication status.
  void setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  void setImgUrl(String imgUrl) {
    _userData.imgUrl = imgUrl;
    saveToFile(_userData.toJSON());
    notifyListeners();
  }

  void setName(String name) {
    _userData.name = name;
    saveToFile(_userData.toJSON());
    notifyListeners();
  }

  /// Update data on user signin/signup.
  void update(UserData dataResp) {
    if (dataResp == null) { return; }

    if (_userData == null) {
      _userData = UserData(
        email: dataResp.email,
        id: dataResp.id,
        imgUrl: dataResp.imgUrl,
        lang: dataResp.lang,
        name: dataResp.name,
        rights: dataResp.rights,
        token: dataResp.token,
      );

      notifyListeners();
      return;
    }

    _userData.email   = dataResp.email  ?? _userData.email;
    _userData.id      = dataResp.id     ?? _userData.id;
    _userData.imgUrl  = dataResp.imgUrl ?? _userData.imgUrl;
    _userData.lang    = dataResp.lang   ?? _userData.lang;
    _userData.name    = dataResp.name   ?? _userData.name;
    _userData.rights  = dataResp.rights ?? _userData.rights;
    _userData.token   = dataResp.token  ?? _userData.token;

    notifyListeners();
  }
}
