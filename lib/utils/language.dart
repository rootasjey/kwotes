import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';

class Language {
  /// Current application's language.
  static String current = 'en';

  static const String en = 'en';
  static const String fr = 'fr';

  static const String english = 'English';
  static const String french = 'Français';

  static List<String> available() {
    return [en, fr];
  }

  static String backend(String lang) {
    switch (lang) {
      case english:
        return en;
      case french:
        return fr;
      default:
        return en;
    }
  }

  static String frontend(String lang) {
    switch (lang) {
      case en:
        return english;
      case fr:
        return french;
      default:
        return english;
    }
  }

  /// Fetch user's lang from database.
  static Future<String> fetch(FirebaseUser userAuth) async {
    if (userAuth == null) {
      String savedLang = appLocalStorage.getLang();
      return savedLang ?? 'en';
     }

    final user = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .get();

    if (user.exists) {
      current = user.data['lang'];
    }

    return current;
  }

  static Future fetchAndPopulate(FirebaseUser userAuth) async {
    String lang = await fetch(userAuth) ?? 'en';
    setLang(lang);
  }

  static void setLang(String lang) {
    userState.setLang(lang);
    appLocalStorage.setLang(lang);
  }
}
