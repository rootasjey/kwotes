import 'dart:html';

class AppLocalStorage {
  static Storage _localStorage = window.localStorage;

  static String getEmail() => _localStorage['email'];
  static String getLang() => _localStorage['lang'];

  static void saveEmail(String email) => _localStorage['email'] = email;
  static void saveLang(String lang) => _localStorage['lang'] = lang;
}
