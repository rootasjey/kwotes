import 'package:flutter/foundation.dart';

import '../types/user_data.dart';

class UserDataModel extends ChangeNotifier {
  UserData _userData;
  bool _isAuthenticated = false;

  UserDataModel({UserData data}) {
    if (data == null) {
      _userData = new UserData();
    }
  }

  /// True if the current user is authenticated.
  bool get isAuthenticated => _isAuthenticated;

  /// User's data.
  UserData get data => _userData;

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
    _userData = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Update user's authentication status.
  void setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  /// Update data on user signin/signup.
  UserDataModel update(UserData data) {
    if (data == null) { return this; }

    if (_userData == null) {
      _userData = UserData(
        email: data.email,
        id: data.id,
        imgUrl: data.imgUrl,
        lang: data.lang,
        name: data.name,
        rights: data.rights,
        token: data.token,
      );

      notifyListeners();
      return this;
    }

    _userData.email   = data.email  ?? _userData.email;
    _userData.id      = data.id     ?? _userData.id;
    _userData.imgUrl  = data.imgUrl ?? _userData.imgUrl;
    _userData.lang    = data.lang   ?? _userData.lang;
    _userData.name    = data.name   ?? _userData.name;
    _userData.rights  = data.rights ?? _userData.rights;
    _userData.token   = data.token  ?? _userData.token;

    notifyListeners();
    return this;
  }
}
