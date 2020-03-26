import 'dart:html';

import 'package:flutter/material.dart';

class AppLocalStorage {
  static Storage _localStorage = window.localStorage;

  static bool getAutoBrightness() {
    return _localStorage['autoBrightness'] == 'true' ? true : false;
  }

  static Brightness getBrightness() {
    final brightness = _localStorage['brightness'] == 'dark' ?
      Brightness.dark : Brightness.light;

    return brightness;
  }

  static String getEmail() => _localStorage['email'];
  static String getLang() => _localStorage['lang'];

  static void saveAutoBrightness(bool value) {
    _localStorage['autoBrightness'] = value.toString();
  }

  static void saveBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage['brightness'] = strBrightness;
  }

  static void saveEmail(String email) => _localStorage['email'] = email;
  static void saveLang(String lang) => _localStorage['lang'] = lang;
}
