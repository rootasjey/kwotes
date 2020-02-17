import 'package:localstorage/localstorage.dart';

class AppLocalStorage {
  static LocalStorage _userStorage;

  static void init() {
    _userStorage = LocalStorage('user');
  }

  static void saveEmail(String email) {
    _userStorage.setItem('email', email);
  }

  static String getEmail() {
    return _userStorage.getItem('email');
  }
}
