import 'dart:html';

import 'package:flutter/material.dart';

class AppLocalStorage {
  static Storage _localStorage = window.localStorage;

  bool getAutoBrightness() {
    return _localStorage['autoBrightness'] == 'false' ? false : true;
  }

  Brightness getBrightness() {
    final brightness = _localStorage['brightness'] == 'dark' ?
      Brightness.dark : Brightness.light;

    return brightness;
  }

  Map<String, String> getCredentials() {
    final credentials = Map<String, String>();

    credentials['email'] = _localStorage['email'];
    credentials['password'] = _localStorage['password'];

    return credentials;
  }

  String getLang() => _localStorage['lang'];

  void saveAutoBrightness(bool value) {
    _localStorage['autoBrightness'] = value.toString();
  }

  void saveBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage['brightness'] = strBrightness;
  }

  void saveEmail(String email) => _localStorage['email'] = email;
  void saveLang(String lang) => _localStorage['lang'] = lang;

  void saveCredentials({String email, String password}) {
    _localStorage['email'] = email;
    _localStorage['password'] = password;
  }
}

final appLocalStorage = AppLocalStorage();
