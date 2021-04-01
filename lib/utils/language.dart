import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/utils/app_storage.dart';

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
  static Future<String> fetch(User userAuth) async {
    if (userAuth == null) {
      String savedLang = appStorage.getLang();
      return savedLang ?? 'en';
    }

    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .get();

    if (user.exists) {
      current = user.data()['lang'];
    }

    return current;
  }

  static Future fetchAndPopulate(User userAuth) async {
    String lang = await fetch(userAuth) ?? 'en';
    setLang(lang);
  }

  static void setLang(String lang) {
    stateUser.setLang(lang);
    appStorage.setLang(lang);
  }
}
